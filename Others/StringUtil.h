//
//  StringUtil.h
//
//

#import <UIKit/UIKit.h>

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
- (NSString*)md5;
- (uint64_t)md5AsInt64;
- (time_t)dateValue;
+ (NSString*)dateString:(time_t)at;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
@end


