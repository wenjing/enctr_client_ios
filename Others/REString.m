//
//  REString.m
//
//

#import <regex.h>
#import <string.h>
#import "REString.h"
//#define DEBUG

@implementation NSString(AWSRegex)

- (BOOL)matches:(NSString *) regex withSubstring:(NSMutableArray *) substring{
	BOOL result = NO;
    regex_t re;
    int ret;
    const char *str = [self UTF8String];
    char buf[strlen([self UTF8String]) + 1];
    if ((ret =regcomp(&re, [regex UTF8String], REG_EXTENDED)) == 0) {
		size_t nmatch = re.re_nsub +1;
		regmatch_t pmatch[nmatch];
		if (0 == regexec(&re, [self UTF8String], nmatch, pmatch, 0)) {
			result = YES;
			if (substring  != nil){
				int i = 1;
				for (i; i < nmatch; i++){
					if (pmatch[i].rm_so == pmatch[i].rm_eo & pmatch[i].rm_so == -1) {
						// there is no matching charaters for this partial expression
						[substring addObject:@""];
					}
					else {
						// return the found expressions
                        int len = pmatch[i].rm_eo - pmatch[i].rm_so;
                        buf[len] = 0;
                        strncpy(buf, &str[pmatch[i].rm_so], len);
                        [substring addObject:[NSString stringWithUTF8String:buf]];
					}
				}
			}
		}
    }
    else {
        char errbuf[100];
        regerror(ret, &re,errbuf,sizeof errbuf);
        NSLog(@"regcomp: %s",errbuf);
    }
    regfree(&re);
    return result;
}
  
@end
