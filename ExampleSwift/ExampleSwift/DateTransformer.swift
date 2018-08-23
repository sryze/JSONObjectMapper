//
//  DateTransformer.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import UIKit

/// DateTransformer converts strings to dates and vice versa.
///
/// You can configure which date format to use via the \c dateFormat parameter in the initializer.
///
class DateTransformer: ValueTransformer {
    
    let dateFormatter: DateFormatter
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return dateFormatter.date(from: (value as? String)!)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return dateFormatter.string(from: (value as? Date)!)
    }
}
