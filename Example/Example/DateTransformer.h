//
//  ViewController.h
//  JSONObjectMapperExample
//
//  Created by Sergey on 20/05/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

/// DateTransformer converts strings to dates and vice versa.
///
/// You can configure which date format to use via the \c dateFormat parameter in the initializer.
///
@interface DateTransformer : NSValueTransformer

/// Initializes a date transformer with a given date formatter.
///
/// \param dateFormatter The date formatter to use.
///
/// \return The newly initialized \c DateTransformer.
- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter;

@end
