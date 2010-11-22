//
//  REString.h
//
//

#import <Foundation/Foundation.h>


@interface NSString(AWSRegex) 
/* This method return the list of all the matching characters (only the one delimited
 * by bracketed sub-expression) in a mutable array.
 * 
 * If an expression is composed of several enclosed sub-expression then the order
 * of the matching sub-string is given from the outermost expression to the innemost
 * and at the same level always from left to right.
 *
 * The escape char for the regex parameter is "\\"
 *
 * Example: regex = "((M)?[0-9]{2})" self = "M12" => substring[0] = 12 , substring[1]=M
 */
- (BOOL)matches:(NSString *) regex withSubstring:(NSMutableArray *) substring;

@end
