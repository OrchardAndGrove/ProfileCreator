//
//  PayloadCellViewItemDatePicker.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-14.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class EditorDatePicker {
    
    class func picker(offsetDays: Int,
                      offsetHours: Int,
                      offsetMinutes: Int,
                      showDate: Bool,
                      showTime: Bool,
                      cellView: PayloadCellView & DatePickerCellView) -> NSDatePicker {
        
        // ---------------------------------------------------------------------
        //  Create and setup Checkbox
        // ---------------------------------------------------------------------
        let datePicker = NSDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerStyle = .textFieldAndStepperDatePickerStyle
        datePicker.datePickerMode = .singleDateMode
        datePicker.target = cellView
        datePicker.action = #selector(cellView.selectDate(_:))
        
        let midnight = Date().midnight()
        datePicker.dateValue = midnight ?? Date()
        
        var offsetComponents = DateComponents()
        offsetComponents.day = offsetDays
        offsetComponents.hour = offsetHours
        offsetComponents.minute = offsetMinutes
        let offsetDate = Calendar.current.date(byAdding: offsetComponents, to: datePicker.dateValue)
        datePicker.minDate = offsetDate
        
        let elements: NSDatePicker.ElementFlags
        
        if !showDate && !showTime {
            elements = .yearMonthDayDatePickerElementFlag
        } else if showDate {
            if showTime {
                elements = [.yearMonthDayDatePickerElementFlag, .hourMinuteDatePickerElementFlag]
            } else {
                elements = .yearMonthDayDatePickerElementFlag
            }
        } else {
            elements = .hourMinuteDatePickerElementFlag
        }
        
        datePicker.datePickerElements = elements
        
        return datePicker
    }
}

