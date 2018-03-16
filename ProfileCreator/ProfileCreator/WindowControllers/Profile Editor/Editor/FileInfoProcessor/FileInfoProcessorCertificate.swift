//
//  FileInfoProcessorCertificate.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

enum CertificateType {
    case pkcs1
    case pkcs12
}

class FileInfoProcessorCertificate: FileInfoProcessor {
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    override init?(data: Data, fileInfo: Dictionary<String, Any>) {
        super.init(data: data, fileInfo: fileInfo)
    }
    
    // MARK: -
    // MARK: Functions
    
    override func fileData() -> Data? {
        if let fileURL = self.fileURL {
            
            // Try reading the file contents as a string
            do {
                let certificateString = try String(contentsOf: fileURL, encoding: .utf8)
                let certificateScanner = Scanner(string: certificateString)
                
                var certificateScannerString: NSString? = ""
                
                // Move to the first line containing '-----BEGIN CERTIFICATE-----'
                certificateScanner.scanUpTo("-----BEGIN CERTIFICATE-----", into: nil)
                
                // Get the string contents between the first '-----BEGIN CERTIFICATE-----' and '-----END CERTIFICATE-----' encountered
                if !( certificateScanner.scanString("-----BEGIN CERTIFICATE-----", into: nil) && certificateScanner.scanUpTo("-----END CERTIFICATE-----", into: &certificateScannerString) ) {
                    return nil
                }
                
                // If the scannerString is not empty, replace the plistString
                if let certificateStringBase64 = certificateScannerString as String?, !certificateStringBase64.isEmpty {
                    return Data(base64Encoded: certificateStringBase64, options: .ignoreUnknownCharacters)
                } 
            } catch {
                return try? Data(contentsOf: fileURL)
            }
            
            return nil
        } else {
            return self.fileDataVar
        }
    }
    
    override func fileInfo() -> FileInfo {
        
        if let fileInfoVar = self.fileInfoVar {
            return fileInfoVar
        } else {
            
            let securityInterfaceBundle = Bundle(identifier: "com.apple.securityinterface") ?? Bundle(path: "/System/Library/Frameworks/SecurityInterface.framework")
            
            var title = ""
            var topLabel = ""
            var centerLabel: String?
            var bottomLabel: String?
            var bottomError = false
            var icon: NSImage?
            
            var certificateType: CertificateType = .pkcs1
            
            if let fileURL = self.fileURL, fileURL.pathExtension == "p12" {
                certificateType = .pkcs12
            }
            
            if certificateType == .pkcs12 {
                
                // Title
                title = NSLocalizedString("Personal Information Exchange", comment: "")
                
                // Top
                topLabel = NSLocalizedString("This content is stored in Personal Information Exchange (PKCS12) format, and is password protected. No information can be displayed.", comment: "")
                
                // Icon
                if let iconURL = securityInterfaceBundle?.urlForImageResource(NSImage.Name(rawValue: "CertLargePersonal")) {
                    icon = NSImage(contentsOf: iconURL)
                }
                
            } else if
                let fileData = self.fileData(),
                let certificate = SecCertificateCreateWithData(nil, fileData as CFData) {
                var errorRef : Unmanaged<CFError>?
                
                let certificateValues = SecCertificateCopyValues(certificate,
                                                                 [kSecOIDX509V1ValidityNotBefore,
                                                                  kSecOIDX509V1ValidityNotAfter,
                                                                  kSecOIDX509V1IssuerName,
                                                                  kSecOIDBasicConstraints,
                                                                  kSecOIDTitle] as CFArray, &errorRef) as? [String: Any]
                let error = errorRef?.takeRetainedValue()
                
                if let certValues = certificateValues {
                    
                    // Title
                    if let certificateTitle = SecCertificateCopySubjectSummary(certificate) { title = certificateTitle as String }
                    
                    // Check if certificate is self signed
                    let issuerData = SecCertificateCopyNormalizedIssuerContent(certificate, &errorRef)
                    let issuerDataError = errorRef?.takeRetainedValue()
                    
                    if issuerData == nil {
                        Swift.print("Failed to get issuer data: \(String(describing: issuerDataError))")
                    }
                    
                    let subjectData = SecCertificateCopyNormalizedSubjectContent(certificate, &errorRef)
                    let subjectDataError = errorRef?.takeRetainedValue()
                    
                    if subjectData == nil {
                        Swift.print("Failed to get subject data: \(String(describing: subjectDataError))")
                    }
                    
                    if issuerData == subjectData {
                        
                        // Icon
                        if let iconURL = securityInterfaceBundle?.urlForImageResource(NSImage.Name(rawValue: "CertLargeRoot")) {
                            icon = NSImage(contentsOf: iconURL)
                        }
                        
                        // Top
                        topLabel = NSLocalizedString("Root certificate authority", comment: "")
                    } else {
                        
                        // Icon
                        if let iconURL = securityInterfaceBundle?.urlForImageResource(NSImage.Name(rawValue: "CertLargeStd")) {
                            icon = NSImage(contentsOf: iconURL)
                        }
                        
                        // Is Certificate Authority
                        var isCertificateAuthority: Bool = false
                        if
                            let basicConstraintsDict = certValues[kSecOIDBasicConstraints as String] as? Dictionary<String, Any>,
                            let basicConstraints = basicConstraintsDict[kSecPropertyKeyValue as String] as? [Dictionary<String, Any>] {
                            isCertificateAuthority = basicConstraints.contains(where: {
                                if
                                    let label = $0[kSecPropertyKeyLabel as String] as? String, label == "Certificate Authority",
                                    let value = $0[kSecPropertyKeyValue as String] as? NSString {
                                    return value.boolValue
                                } else { return false }
                            })
                        }
                        
                        // Top
                        if isCertificateAuthority {
                            topLabel = NSLocalizedString("Intermediate certificate authority", comment: "")
                        } else {
                            if
                                let issuersDict = certValues[kSecOIDX509V1IssuerName as String] as? Dictionary<String, Any>,
                                let issuers = issuersDict[kSecPropertyKeyValue as String] as? [Dictionary<String, Any>],
                                let issuer = issuers.first,
                                let issuerName = issuer[kSecPropertyKeyValue as String] as? String {
                                topLabel = NSLocalizedString("Issued by: \(issuerName)", comment: "")
                            } else {
                                topLabel = NSLocalizedString("Unknwon Issuer", comment: "")
                            }
                        }
                        
                        // Not Valid Before
                        if
                            let notValidBeforeDict = certValues[kSecOIDX509V1ValidityNotBefore as String] as? Dictionary<String, Any>,
                            let notValidBefore = notValidBeforeDict[kSecPropertyKeyValue as String] as? Double,
                            let notValidBeforeDate = CFDateCreate(kCFAllocatorDefault, notValidBefore) as Date? {
                            
                            if notValidBeforeDate.compare(Date()) == ComparisonResult.orderedDescending {
                                
                                // Center
                                centerLabel = NSLocalizedString("Not valid before: \(DateFormatter.localizedString(from: notValidBeforeDate, dateStyle: .long, timeStyle: .long))", comment: "")
                                
                                // Bottom
                                bottomLabel = NSLocalizedString("This certificate is not yet valid", comment: "")
                                bottomError = true
                            }
                        }
                        
                        // Not Valid After
                        if
                            !bottomError,
                            let notValidAfterDict = certValues[kSecOIDX509V1ValidityNotAfter as String] as? Dictionary<String, Any>,
                            let notValidAfter = notValidAfterDict[kSecPropertyKeyValue as String] as? Double,
                            let notValidAfterDate = CFDateCreate(kCFAllocatorDefault, notValidAfter) as Date? {
                            
                            if notValidAfterDate.compare(Date()) == ComparisonResult.orderedAscending {
                                
                                // Center
                                centerLabel = NSLocalizedString("Expired: \(DateFormatter.localizedString(from: notValidAfterDate, dateStyle: .long, timeStyle: .long))", comment: "")
                                
                                // Bottom
                                bottomLabel = NSLocalizedString("This certificate has expired", comment: "")
                                bottomError = true
                            } else {
                                
                                // Center
                                centerLabel = NSLocalizedString("Expires: \(DateFormatter.localizedString(from: notValidAfterDate, dateStyle: .long, timeStyle: .long))", comment: "")
                            }
                        }
                    }
                } else {
                    Swift.print("Failed to get certificate values: \(String(describing: error))")
                }
            } else {
                Swift.print("Could not get the file Data, this is an error and should notify the user.")
            }
            
            if icon == nil {
                icon = NSWorkspace.shared.icon(forFileType: self.fileUTI)
            }
            
            // FIXME: Need to fix defaults here
            self.fileInfoVar = FileInfo(title: title,
                                        topLabel: topLabel,
                                        topContent: "",
                                        topError: false,
                                        centerLabel: centerLabel,
                                        centerContent: nil,
                                        centerError: false,
                                        bottomLabel: bottomLabel,
                                        bottomContent: nil,
                                        bottomError: bottomError,
                                        icon: icon)
            return self.fileInfoVar!
        }
    }
}
