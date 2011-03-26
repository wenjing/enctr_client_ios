
//  DBconnection.m
//
//  Created by Jun Li on 10/25/2010.
//  Copyright 2010 Kaya Labs, Inc. All rights reserved.
//

#import "DBConnection.h"
#import "Statement.h"
#import "kaya_meetAppDelegate.h"

static sqlite3*   theDatabase = nil;

#define MAIN_DATABASE_NAME @"Cirkle-db.sql"

//#define TEST_DELETE_MEETS

#ifdef TEST_DELETE_MEETS
const char *delete_meets = 
"BEGIN;"
"DELETE FROM users;"
"DELETE FROM meets;"
"COMMIT";
#endif

@implementation DBConnection

+ (sqlite3*)openDatabase:(NSString*)dbFilename
{
    sqlite3* instance;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(instance);
        NSLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        theDatabase = [self openDatabase:MAIN_DATABASE_NAME];
        if (theDatabase == nil) {
            [DBConnection createEditableCopyOfDatabaseIfNeeded:true];
            [[kaya_meetAppDelegate getAppDelegate] alert:@"Local cache error" 
			  message:@"Local cache database has been corrupted. Re-created new database."];
        }
        
#ifdef TEST_DELETE_MEETS
        char *errmsg;
        if (sqlite3_exec(theDatabase, delete_meets, NULL, NULL, &errmsg) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
        }
#endif
    }
    return theDatabase;
}

//
// delete caches
//
const char *delete_users_cache_sql = 
"BEGIN;"
"DELETE FROM users;"
"COMMIT;"
"VACUUM;";
const char *delete_meets_cache_sql = 
"BEGIN;"
"DELETE FROM meets;"
"COMMIT;"
"VACUUM;";
const char *delete_news_cache_sql = 
"BEGIN;"
"DELETE FROM news;"
"COMMIT;"
"VACUUM;";
const char *delete_cirkles_cache_sql = 
"BEGIN;"
"DELETE FROM cirkles;"
"COMMIT;"
"VACUUM;";

+ (void)deleteDBCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, delete_users_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup users chache (%s)", errmsg);
    }
    if (sqlite3_exec(theDatabase, delete_meets_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup meets chache (%s)", errmsg);
    }
    if (sqlite3_exec(theDatabase, delete_news_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup news chache (%s)", errmsg);
    }
    if (sqlite3_exec(theDatabase, delete_cirkles_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup crikles chache (%s)", errmsg);
    }
}

//
// cleanup and optimize
//
const char *cleanup_sql =
"BEGIN;"
"COMMIT";

const char *optimize_sql = "VACUUM; ANALYZE";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            // ignore error
            NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
        
      	int launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        NSLog(@"launchCount %d", launchCount);
        if (launchCount-- <= 0) {
            NSLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 50;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
        
    // No exists any database file. Create new one.
    //
	if (force) {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    success = [fileManager fileExistsAtPath:writableDBPath];
	
    if (success) {
		NSLog(@"user db : %@", writableDBPath);
		return;
	}
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	NSLog(@"create new : %@", writableDBPath);
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+ (void)beginTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);     
}

+ (void)commitTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);     
}

+ (Statement*)statementWithQuery:(const char *)sql
{
    Statement* stmt = [Statement statementWithDB:theDatabase query:sql];
    return stmt;
}

+ (void)alert
{
    NSString *sqlite3err = [NSString stringWithUTF8String:sqlite3_errmsg(theDatabase)];
    [[kaya_meetAppDelegate getAppDelegate] alert:@"Local cache db error" message:sqlite3err];
}

@end
