//
//  PayloadCellViewFile.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewFile: NSTableCellView, ProfileCreatorCellView, PayloadCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldHost: PayloadTextField?
    var fileView: FileView?
    let buttonAdd = PayloadButton()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, editor: ProfileEditor, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        self.editor = editor
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let textFieldTitle = EditorTextField.title(subkey: subkey, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self) {
            self.textFieldTitle = textFieldTitle
        }
        
        if let textFieldDescription = EditorTextField.description(subkey: subkey, constraints: &constraints, cellView: self) {
            self.textFieldDescription = textFieldDescription
        }
        
        // ---------------------------------------------------------------------
        //  Read accepted file UTIs from subkey
        // ---------------------------------------------------------------------
        // FIXME: This needs to be fixed and decided how it should be set in the config
        // let acceptedFileUTIs = [String]()
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.fileView = EditorFileView.view(acceptedFileUTIs: nil, constraints: &constraints, cellView: self)
        addConstraintsFor(item: self.fileView!, orientation: .below, constraints: &constraints, cellView: self)
        setupButtonAdd(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if
            let domainSettings = settings[subkey.domain] as? Dictionary<String, Any>,
            let valueData = domainSettings[subkey.keyPath] as? Data,
            let valueFileInfo = domainSettings[SettingsKey.fileInfo] as? Dictionary<String, Any>,
            self.processFile(data: valueData, fileInfo: valueFileInfo) {
            self.showPrompt(false)
        } else {
            self.showPrompt(true)
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.buttonAdd
        self.trailingKeyView = self.buttonAdd
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    func enable(_ enable: Bool) {
        Swift.print("File Enable: \(enable)")
    }
    
    // MARK: -
    // MARK: Private Functions
    func showPrompt(_ show: Bool) {
        guard let fileView = self.fileView else { return }
        fileView.imageViewIcon.isHidden = show
        fileView.textFieldTitle.isHidden = show
        fileView.textFieldTopLabel.isHidden = show
        fileView.textFieldTopContent.isHidden = show
        fileView.textFieldCenterLabel.isHidden = show
        fileView.textFieldCenterContent.isHidden = show
        fileView.textFieldBottomLabel.isHidden = show
        fileView.textFieldBottomContent.isHidden = show
        fileView.textFieldPropmpt.isHidden = !show
    }
    
    // MARK: -
    // MARK: Button Actions
    
    @objc private func selectFile(_ button: NSButton) {
        
        // ---------------------------------------------------------------------
        //  Get open dialog allowed file types
        // ---------------------------------------------------------------------
        // FIXME: Read these from the collection manifest
        let allowedFileTypes = [String]()
        
        // ---------------------------------------------------------------------
        //  Setup open dialog
        // ---------------------------------------------------------------------
        let openPanel = NSOpenPanel()
        openPanel.prompt = !self.buttonAdd.title.isEmpty ? self.buttonAdd.title : "Select File"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        
        if 0 < allowedFileTypes.count {
            openPanel.allowedFileTypes = allowedFileTypes
        }
        
        if let window = button.window {
            openPanel.beginSheetModal(for: window) { (response) in
                if response == .OK, let url = openPanel.urls.first {
                    self.processFile(atURL: url, completionHandler: { (success) in
                        self.showPrompt(!success)
                    })
                }
            }
        }
    }
    
    // MARK: -
    // MARK: Process File
    
    private func processFile(data: Data, fileInfo: Dictionary<String, Any>) -> Bool {
        if let fileInfoProcessor = FileInfoProcessor(data: data, fileInfo: fileInfo) {
            return self.updateView(fileInfo: fileInfoProcessor.fileInfo())
        }
        return false
    }
    
    func processFile(atURL url: URL, completionHandler: @escaping (_ success: Bool) -> Void) {
        guard let subkey = self.subkey else { completionHandler(false); return }
        
        var alertShow = false
        var alertMessage = ""
        var alertInformativeMessage = ""
        
        let fileInfoProcessor = FileInfoProcessor(fileURL: url)
        guard let fileData = fileInfoProcessor.fileData() else { completionHandler(false); return }
        let fileInfo = fileInfoProcessor.fileInfo()
        let fileInfoDict = fileInfoProcessor.fileInfoDict()
        
        // ---------------------------------------------------------------------
        //  Verify the file size is reasonable (< 1.0 MB)
        // ---------------------------------------------------------------------
        var fileSize: Int64 = -1
        if
            let fileAttributes = fileInfoDict[FileInfoKey.fileAttributes] as? [FileAttributeKey : Any],
            let fileSizeBytes = fileAttributes[.size] as? Int64 {
            fileSize = fileSizeBytes
        }
 
        let formatter = ByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        formatter.countStyle = .file
        formatter.allowedUnits = [.useMB]
        formatter.includesUnit = false
        let fileSizeString = formatter.string(fromByteCount: fileSize)
        if let fileSizeMB = Double(fileSizeString.replacingOccurrences(of: ",", with: ".")) {
            if 1.0 < fileSizeMB {
                alertShow = true
                alertMessage = NSLocalizedString("Large File Size", comment: "")
                alertInformativeMessage = NSLocalizedString("The file you have selected is: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)). Are you sure you want to continue?", comment: "")
            } else if fileSizeMB < 0.0 {
                alertShow = true
                alertMessage = NSLocalizedString("Unknown File Size", comment: "")
                alertInformativeMessage = NSLocalizedString("Could not determine the size of the selected file. Are you sure you want to continue?", comment: "")
            }
        } else {
            alertShow = true
            alertMessage = NSLocalizedString("Unknown File Size", comment: "")
            alertInformativeMessage = NSLocalizedString("Could not determine the size of the selected file. Are you sure you want to continue?", comment: "")
        }
        
        // ---------------------------------------------------------------------
        //  If any issues was found with the file size, show alert
        // ---------------------------------------------------------------------
        if alertShow {
            guard let window = self.buttonAdd.window else { completionHandler(false); return }
            let alert = Alert()
            alert.showAlert(message: alertMessage,
                            informativeText: alertInformativeMessage,
                            window: window,
                            firstButtonTitle: ButtonTitle.ok,
                            secondButtonTitle: ButtonTitle.cancel,
                            thirdButtonTitle: nil,
                            firstButtonState: true,
                            sender: nil,
                            returnValue: { (response) in
                                if response == .alertFirstButtonReturn {
                                    if self.updateView(fileInfo: fileInfo) {
                                        self.editor?.updatePayloadSettings(value: fileInfoDict, key: SettingsKey.fileInfo, subkey: subkey)
                                        self.editor?.updatePayloadSettings(value: fileData, subkey: subkey)
                                    }
                                    completionHandler(true); return
                                } else {
                                    completionHandler(false); return
                                }
            })
        } else {
            if self.updateView(fileInfo: fileInfo) {
                self.editor?.updatePayloadSettings(value: fileInfoDict, key: SettingsKey.fileInfo, subkey: subkey)
                self.editor?.updatePayloadSettings(value: fileData, subkey: subkey)
            }
            completionHandler(true); return
        }
    }
    
    private func updateView(fileInfo: FileInfo) -> Bool {
        guard let fileView = self.fileView else { return false }
        
        fileView.textFieldTitle.stringValue = fileInfo.title
        
        // Top
        fileView.textFieldTopLabel.stringValue = fileInfo.topLabel
        fileView.textFieldTopContent.stringValue = fileInfo.topContent
        
        // Center
        fileView.textFieldCenterLabel.stringValue = fileInfo.centerLabel ?? ""
        fileView.textFieldCenterContent.stringValue = fileInfo.centerContent ?? ""
        
        // Bottom
        fileView.textFieldBottomLabel.stringValue = fileInfo.bottomLabel ?? ""
        fileView.textFieldBottomContent.stringValue = fileInfo.bottomContent ?? ""
        
        // Icon
        fileView.imageViewIcon.image = fileInfo.icon
        
        return true
    }
}

// MARK: -
// MARK: Setup Layout Constraints

extension PayloadCellViewFile {
    private func setupButtonAdd(constraints: inout [NSLayoutConstraint]) {
        guard let fileView = self.fileView else { return }
        
        self.buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        self.buttonAdd.bezelStyle = .rounded
        self.buttonAdd.setButtonType(.momentaryPushIn)
        self.buttonAdd.isBordered = true
        self.buttonAdd.isTransparent = false
        self.buttonAdd.title = NSLocalizedString("Add", comment: "")
        self.buttonAdd.target = self
        self.buttonAdd.action = #selector(self.selectFile(_:))
        self.buttonAdd.sizeToFit()
        self.buttonAdd.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.addSubview(self.buttonAdd)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.buttonAdd,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: fileView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        self.updateHeight((8 + self.buttonAdd.intrinsicContentSize.height))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.buttonAdd,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: self.buttonAdd,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
}
