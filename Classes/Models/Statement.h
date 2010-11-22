//
//  Statement.h
//
//  Created by Jun Li on 10/25/2010.
//  Copyright 2010 Kaya Labs, Inc. All rights reserved.
//

#import <sqlite3.h>

//
// Interface for Statement
//
@interface Statement : NSObject
{
    sqlite3_stmt*   stmt;
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql;
- (id)initWithDB:(sqlite3*)db query:(const char*)sql;

// method
- (int)step;
- (void)reset;

// Getter
- (NSString*)getString:(int)index;
- (int)getInt32:(int)index;
- (long long)getInt64:(int)index;
- (NSData*)getData:(int)index;

// Binder
- (void)bindString:(NSString*)value forIndex:(int)index;
- (void)bindInt32:(int)value forIndex:(int)index;
- (void)bindInt64:(long long)value forIndex:(int)index;
- (void)bindData:(NSData*)data forIndex:(int)index;

@end

