//
//  DBConnectionManager
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "sqlite3.h"

/*
 *   bridge to sqlite database 
 */
@interface DBConnectionManager : NSObject{
    
}

+ (instancetype)sharedDBConnectionManager;

#pragma mark -  method to create db and get the connection
-(void)createEditableCopyOfDatabaseIfNeeded;
-(sqlite3 *)getNewDBConnection;
-(void)deleteDatabase;


#pragma mark - common method
-(int)getIntValue:(sqlite3 *)contactDB queryStr:(NSString*)querySQL;
-(void)execute:(NSString*)sql;
 
@end
