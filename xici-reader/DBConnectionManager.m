//
//  DBConnectionManager
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "DBConnectionManager.h"
#import "Constants.h"
#import "XiciCategory.h"
 
#import "LocalService.h"



@interface DBConnectionManager ()

@end

@implementation DBConnectionManager


+ (instancetype)sharedDBConnectionManager
{
    static dispatch_once_t onceToken;
    static DBConnectionManager * dbConnectionManager;
    dispatch_once(&onceToken, ^{
        dbConnectionManager = [[[self class] alloc] init];
        [dbConnectionManager createEditableCopyOfDatabaseIfNeeded];
    });
    return dbConnectionManager;
}


#pragma mark -  method to create db and get the connection
- (void)createEditableCopyOfDatabaseIfNeeded{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDATABSE_NAME];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent: kDATABSE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSLog( @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    } else {
        [self addSkipBackupAttributeToItemAtPath:writableDBPath];
     
    }
}




-(void)deleteDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kDATABSE_NAME];
     NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    if ( !success  ){
        NSLog(@"Error clearDocumentFile  %@ with error %@", path , error);
    }
}

-(sqlite3 *) getNewDBConnection{
    [self createEditableCopyOfDatabaseIfNeeded];
    sqlite3 *newDBconnection;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kDATABSE_NAME];
    if (sqlite3_open([path UTF8String], &newDBconnection) == SQLITE_OK) {
  } else {
        NSLog(@"Error in opening database");
    }
   // [newDBconnection executeUpdate:@"PRAGMA foreign_keys=ON"];
    
    return newDBconnection;
}

#pragma mark - common method
-(void)execute:(NSString*)querySQL{
    sqlite3 *contactDB = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
    
    if ( contactDB == nil )
        return;
    const char* query_stmt = [querySQL UTF8String];
    
    char *errMsg;
    if (sqlite3_exec(contactDB, query_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
       NSLog( @"Failed to execute  %@", querySQL);
    }
    
  //  sqlite3_exec(contactDB, query_stmt, NULL, NULL, NULL);
  //  sqlite3_finalize(query_stmt);
    
    sqlite3_close(contactDB);
}

-(int)getIntValue:(sqlite3 *)contactDB queryStr:(NSString*)querySQL{
    sqlite3_stmt    *statement;
    const char *query_stmt = [querySQL UTF8String];
    
    sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
    int value =0;
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        value =   sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
    
    return value;
    
}

//help method
//for iOS 5.1 and later. Starting in iOS 5.1, apps can use either NSURLIsExcludedFromBackupKey or kCFURLIsExcludedFromBackupKey file properties to exclude files from backups.
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path{
    return  [self addSkipBackupAttributeToItemAtURL: [NSURL fileURLWithPath:path]];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
        return FALSE;
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


@end

 