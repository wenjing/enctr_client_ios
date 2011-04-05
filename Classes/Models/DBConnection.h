//  DBconnection.h
//
//  Created by Jun Li on 10/25/2010.
//  Copyright 2010 Kaya Labs, Inc. All rights reserved.
//


#import <sqlite3.h>
#import "Statement.h"

//
// Interface for Database connector
//
@interface DBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
+ (void)deleteDBCache;

+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (Statement*)statementWithQuery:(const char*)sql;

+ (void)alert;
+ (sqlite3_uint64)lastInsertId;

@end
