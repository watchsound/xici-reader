//
//  ForumDAO.m
//  西祠利器
//
//  Created by Hanning Ni on 11/22/13.
//  Copyright (c) 2013 remember9. All rights reserved.
//

#import "ForumDAO.h"
#import "DBConnectionManager.h"

@implementation ForumDAO

+ (instancetype)sharedForumDAO
{
    static dispatch_once_t onceToken;
    static ForumDAO * forumDAO;
    dispatch_once(&onceToken, ^{
        forumDAO = [[[self class] alloc] init];
    });
    return forumDAO;
}

#pragma mark - help function
-(__strong const char *)getUTFString:(NSString*)value{
    NSString* _value = value == nil ? @"" : value;
    return [_value UTF8String];
}

-(double)getTime:(NSDate*)date{
    return date == nil ? 0 : [date timeIntervalSince1970];
}

-(void)saveImage:(NSString*)containerId imageId:(NSString*)imageId image:(NSData*)image{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return;
        /*static */ sqlite3_stmt *compiledStatement = nil;
        
        if(compiledStatement == nil) {
            const char *sql = "INSERT INTO images VALUES(?,?,?, ?)";
            
            if(sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK)
                NSLog(@"Error while creating saveImage statement. %s", sqlite3_errmsg(db));
        }
         sqlite3_bind_text(compiledStatement, 2, [self getUTFString:imageId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 3, [self getUTFString:containerId], -1, SQLITE_TRANSIENT);
        
       
        
        int returnValue = -1;
        if(image != nil)
            returnValue = sqlite3_bind_blob(compiledStatement, 4, [image bytes], (int)[image length], NULL);
        else
            returnValue = sqlite3_bind_blob(compiledStatement, 4, nil, -1, NULL);
        
        
        if(returnValue != SQLITE_OK)
            NSLog(@"saveImage Not OK!!!  containerId = %@  imageId = %@", containerId, imageId);
        
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
            NSLog(@"Error while saveImage  . %s", sqlite3_errmsg(db));
        sqlite3_finalize(compiledStatement);
        sqlite3_close(db);
        
    }
}



-(NSData*)getImage:(NSString*)imageId{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT content FROM images WHERE image_uuid like '%%%@%%'", imageId] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getImage statement. %s for imageId = %@", sqlite3_errmsg(db), imageId);
        
        NSData *data = nil;
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 0) length:sqlite3_column_bytes(statement, 0)];
            
            if(data == nil)
                NSLog(@"No media content  found for %@", imageId);
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return data;
    }
}

-(NSMutableArray*)getImageByContainerId:(NSString*)containId{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT content FROM images WHERE container_id like '%%%@%%'", containId] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getImage statement. %s for imageId = %@", sqlite3_errmsg(db), containId);
        
        NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:4];
        while  (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            [result addObject:[[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 0) length:sqlite3_column_bytes(statement, 0)]];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return result;
    }
}

-(void)saveForum:(Forum*)forum{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return;
        /*static */ sqlite3_stmt *compiledStatement = nil;
        
        if(compiledStatement == nil) {
            const char *sql = "INSERT INTO forums VALUES(?,?,?, ?,?,?,?, ?)";
            
            if(sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK)
                NSLog(@"Error while creating saveForum statement. %s", sqlite3_errmsg(db));
        }
         sqlite3_bind_text(compiledStatement, 1, [self getUTFString:forum.forumId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, [self getUTFString:forum.forumTitle], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 3, [self getUTFString:forum.category], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 4, [self getUTFString:forum.subcategory], -1, SQLITE_TRANSIENT);
        
        
        
        
        int returnValue = -1;
        if(forum.forumIcon != nil)
            returnValue = sqlite3_bind_blob(compiledStatement, 5, [forum.forumIcon bytes], (int)[forum.forumIcon length], NULL);
        else
            returnValue = sqlite3_bind_blob(compiledStatement, 5, nil, -1, NULL);
        
         sqlite3_bind_int(compiledStatement, 6, forum.subscribed ? 1 : 0);
          sqlite3_bind_int(compiledStatement, 7, forum.topForum ? 1 : 0);
        sqlite3_bind_text(compiledStatement, 8, [self getUTFString:forum.iconLocal], -1, SQLITE_TRANSIENT);
        
        
        if(returnValue != SQLITE_OK)
            NSLog(@"saveForum Not OK!!!  forumId  = %@", forum.forumId);
        
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
            NSLog(@"Error while saveForum  . %s", sqlite3_errmsg(db));
        sqlite3_finalize(compiledStatement);
        sqlite3_close(db);
        
    }

}


-(Forum*)parseForum:(sqlite3_stmt *)statement{
    Forum* card = [[Forum alloc] init];
    
   
    card.forumId =   [[NSString alloc] initWithUTF8String:
                       (const char *) sqlite3_column_text(statement, 0)];
    card.forumTitle =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 1)];
    card.category =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 2)];
    card.subcategory =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 3)];
    card.forumIcon =   [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 4) length:sqlite3_column_bytes(statement, 4)];
    
    card.subscribed =  sqlite3_column_int(statement, 5);
    card.topForum =  sqlite3_column_int(statement, 6);
    card.iconLocal =   [[NSString alloc] initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 7)];
    return card;
}

-(Forum*)getForum:(NSString*)forumId{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM forums WHERE forum_id like '%%%@%%'", forumId] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getForum statement. %s for forumId = %@", sqlite3_errmsg(db), forumId);
        
        Forum* forum = nil;
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            forum = [self parseForum:statement];
           
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return forum;
    }
}

-(NSMutableArray*)getForumByCategory:(NSString*)category isTopCategory:(BOOL)topCategory rangeStart:(int)startIndex size:(int)size{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = nil;
        
        if ( topCategory )
           querySQL = [NSString stringWithFormat:@"SELECT * FROM forums WHERE forum_category like '%%%@%%' LIMIT %i OFFSET %i", category, size, startIndex] ;
        else
           querySQL = [NSString stringWithFormat:@"SELECT * FROM forums WHERE forum_sub_category like '%%%@%%' LIMIT %i OFFSET %i", category, size, startIndex] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getForumByCategory statement. %s for forumId = %@", sqlite3_errmsg(db), category);
        
        NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
        while  (sqlite3_step(statement) == SQLITE_ROW)
        {
            
           [result addObject:[self parseForum:statement]];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return result;
    }
}

-(NSMutableArray*)getSubscribedForums{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = @"SELECT * FROM forums WHERE subscribed  = 1"  ;
                 
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getSubscribedForums statement. %s  ", sqlite3_errmsg(db) );
        
        NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
        while  (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            [result addObject:[self parseForum:statement]];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return result;
    }

}

-(void)subscribeForum:(Forum*)forum subscribe:(BOOL)subscribe{
    NSString* querySQL =[NSString stringWithFormat:@"UPDATE forums SET subscribed = %i   WHERE forum_id like '%%%@%%'",   forum.subscribed ? 1 : 0,  forum.forumId ];
    
    [[DBConnectionManager sharedDBConnectionManager] execute:querySQL];
}

-(void)saveUser:(User*)user{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return;
        /*static */ sqlite3_stmt *compiledStatement = nil;
        
        if(compiledStatement == nil) {
            const char *sql = "INSERT INTO users VALUES(?,?,?, ?,?, ?)";
            
            if(sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK)
                NSLog(@"Error while creating saveUser statement. %s", sqlite3_errmsg(db));
        }
         sqlite3_bind_text(compiledStatement, 1, [self getUTFString:user.userId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, [self getUTFString:user.userName], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(compiledStatement, 3, user.sex ? 1 : 0);
        sqlite3_bind_int(compiledStatement, 4, user.isFriend ? 1 : 0);
        sqlite3_bind_int(compiledStatement, 5, user.isFan ? 1 : 0);
        
        
        
        int returnValue = -1;
        if(user.userIcon != nil)
            returnValue = sqlite3_bind_blob(compiledStatement, 6, [user.userIcon bytes], (int)[user.userIcon length], NULL);
        else
            returnValue = sqlite3_bind_blob(compiledStatement, 6, nil, -1, NULL);
        
        
        if(returnValue != SQLITE_OK)
            NSLog(@"save user.userName Not OK!!!   user.userName  = %@", user.userName);
        
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
            NSLog(@"Error while saveUser  . %s", sqlite3_errmsg(db));
        sqlite3_finalize(compiledStatement);
        sqlite3_close(db);
        
    }

}


-(int)getSubscribedForumNum{
     sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
    NSString* queryStr = @"SELECT count(forum_id) as id FROM forums";
    int idvalue = [[DBConnectionManager sharedDBConnectionManager] getIntValue:db queryStr:queryStr];
    
    sqlite3_close(db);
    return idvalue;

}

-(void)updateUser:(User*)user{
    NSString* querySQL =[NSString stringWithFormat:@"UPDATE users SET friends = %i , fan = %i WHERE user_id like '%%%@%%'",   user.isFriend ? 1 : 0,  user.isFan ? 1 : 0, user.userId ];

    [[DBConnectionManager sharedDBConnectionManager] execute:querySQL];
}


-(User*)parseUser:(sqlite3_stmt *)statement{
    User* card = [[User alloc] init];
    
    card.userId =  [[NSString alloc] initWithUTF8String:
                    (const char *) sqlite3_column_text(statement, 0)];
    card.userName =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 1)];
    card.sex =    sqlite3_column_int(statement, 2);;
    card.isFriend =    sqlite3_column_int(statement, 3);
    card.isFan =  sqlite3_column_int(statement, 4);
    card.userIcon =   [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 5) length:sqlite3_column_bytes(statement, 5)];
    
    
    return card;
}


-(User*)getUserByName:(NSString*)name{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM users WHERE user_name like '%%%@%%'", name] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getUserByName statement. %s for forumId = %@", sqlite3_errmsg(db), name);
        
        User* user = nil;
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            user = [self parseUser:statement];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return user;
    }
}

-(User*)getUserById:(NSString*)name{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM users WHERE user_id like '%%%@%%'", name] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getUserByName statement. %s for forumId = %@", sqlite3_errmsg(db), name);
        
        User* user = nil;
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            user = [self parseUser:statement];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return user;
    }
}

-(NSMutableArray*)getFriends{
    sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
    if ( db == nil )
        return nil;
    
    sqlite3_stmt    *statement;
    NSString *querySQL =  @"SELECT * FROM users WHERE friend = 1 "  ;
    
    
    const char *query_stmt = [querySQL UTF8String];
    
    if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
        NSLog(@"Error while   getFriends statement. %s  ", sqlite3_errmsg(db) );
    
    NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:4];
    while  (sqlite3_step(statement) == SQLITE_ROW)
    {
        [users addObject: [self parseUser:statement]];
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    return users;

}

-(NSMutableArray*)getFans{
    sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
    if ( db == nil )
        return nil;
    
    sqlite3_stmt    *statement;
    NSString *querySQL =  @"SELECT * FROM users WHERE fan = 1 "  ;
    
    
    const char *query_stmt = [querySQL UTF8String];
    
    if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
        NSLog(@"Error while   getFriends statement. %s  ", sqlite3_errmsg(db) );
    
    NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:4];
    while  (sqlite3_step(statement) == SQLITE_ROW)
    {
        [users addObject: [self parseUser:statement]];
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    return users;
}


-(void)saveDiscussion:(Discussion*)discussion{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return;
        /*static */ sqlite3_stmt *compiledStatement = nil;
        
        if(compiledStatement == nil) {
            const char *sql = "INSERT INTO discussion VALUES(?,?,?, ?,?,?, ?,?)";
            
            if(sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK)
                NSLog(@"Error while creating saveDiscussion statement. %s", sqlite3_errmsg(db));
        }
        
        sqlite3_bind_text(compiledStatement, 1, [self getUTFString:discussion.discussionId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 2, [self getUTFString:discussion.forumId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 3, [self getUTFString:discussion.userId], -1, SQLITE_TRANSIENT);
        
        
        sqlite3_bind_text(compiledStatement, 4, [self getUTFString:discussion.content], -1, SQLITE_TRANSIENT);
         sqlite3_bind_int64 (compiledStatement, 5,  discussion.timestamp);
        sqlite3_bind_int64 (compiledStatement, 6,  discussion.lastUpdate);
        sqlite3_bind_int (compiledStatement, 7,  discussion.totalReply);
        
        sqlite3_bind_text(compiledStatement, 8, [self getUTFString:discussion.title], -1, SQLITE_TRANSIENT);
        
        
        
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
            NSLog(@"Error while saveDiscussion  . %s", sqlite3_errmsg(db));
        sqlite3_finalize(compiledStatement);
        sqlite3_close(db);
        
    }

}


-(Discussion*)parseDiscussion:(sqlite3_stmt *)statement{
    Discussion* card = [[Discussion alloc] init];
    
    
    card.discussionId =   [[NSString alloc] initWithUTF8String:
                       (const char *) sqlite3_column_text(statement, 0)];
    card.forumId =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 1)];
    card.userId =    [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 2)];
    card.content =  [[NSString alloc] initWithUTF8String:
                     (const char *) sqlite3_column_text(statement,3)];
    card.timestamp =   sqlite3_column_int64(statement, 4);
    card.lastUpdate =   sqlite3_column_int64(statement, 5);
    card.totalReply =   sqlite3_column_int64(statement, 6);
    card.title =  [[NSString alloc] initWithUTF8String:
                   (const char *) sqlite3_column_text(statement,7)];
    
    return card;
}

-(Discussion*)getDisscussion:(NSString*)discussionId{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM discussion WHERE discussion_id like '%%%@%%'", discussionId] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getDisscussion statement. %s for forumId = %@", sqlite3_errmsg(db), discussionId);
        
        Discussion* user = nil;
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            user = [self parseDiscussion:statement];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return user;
    }

}

-(NSMutableArray*)getDisscussions {
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM discussion"] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getDisscussions statement. %s  ", sqlite3_errmsg(db) );
        
        NSMutableArray* discussionList = [[NSMutableArray alloc] initWithCapacity:4];
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            [discussionList addObject: [self parseDiscussion:statement]];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return discussionList;
    }
    
}

-(void)deleteDisscussion:(NSString*)discussionId{
    
    NSString* querySQL =[NSString stringWithFormat:@"DELETE FROM discussion WHERE discussion_id like '%%%@%%'", discussionId];
    [[DBConnectionManager sharedDBConnectionManager] execute:querySQL];
}

-(void)saveDiscussionReply:(DiscussionReply*)discussion{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return;
        /*static */ sqlite3_stmt *compiledStatement = nil;
        
        if(compiledStatement == nil) {
            const char *sql = "INSERT INTO discussion_reply VALUES(?,?,?, ?,?,? )";
            
            if(sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK)
                NSLog(@"Error while creating DiscussionReply statement. %s", sqlite3_errmsg(db));
        }
        
       
        sqlite3_bind_text(compiledStatement, 2, [self getUTFString:discussion.discussionId], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int (compiledStatement, 3,  discussion.discussionOrderNum);
        
        
        sqlite3_bind_text(compiledStatement, 4, [self getUTFString:discussion.userName], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(compiledStatement, 5, [self getUTFString:discussion.content], -1, SQLITE_TRANSIENT);
     
        sqlite3_bind_int64 (compiledStatement, 6,  discussion.timestamp);
        
        
        if(SQLITE_DONE != sqlite3_step(compiledStatement))
            NSLog(@"Error while saveDiscussionReply  . %s", sqlite3_errmsg(db));
        sqlite3_finalize(compiledStatement);
        sqlite3_close(db);
        
    }

}

-(DiscussionReply*)parseDiscussionReply:(sqlite3_stmt *)statement{
    DiscussionReply* card = [[DiscussionReply alloc] init];
    
    card.discussionReplyId =   sqlite3_column_int64(statement, 0);
    card.discussionId =   [[NSString alloc] initWithUTF8String:
                           (const char *) sqlite3_column_text(statement, 1)];
    card.discussionOrderNum =   sqlite3_column_int64(statement, 2);
    
    card.userName =   [[NSString alloc] initWithUTF8String:
                      (const char *) sqlite3_column_text(statement, 3)];
    
    card.content =  [[NSString alloc] initWithUTF8String:
                     (const char *) sqlite3_column_text(statement,4)];
    card.timestamp =   sqlite3_column_int64(statement, 5);
   
    
    return card;
}

-(NSMutableArray*)getDiscussionReply:(NSString*)discussionId{
    @synchronized (self){
        sqlite3 *db = [[DBConnectionManager sharedDBConnectionManager] getNewDBConnection];
        if ( db == nil )
            return nil;
        
        sqlite3_stmt    *statement;
        NSString *querySQL = nil;
        
            querySQL = [NSString stringWithFormat:@"SELECT * FROM discussion_reply WHERE discussion_id like '%%%@%%'  ", discussionId] ;
        
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) != SQLITE_OK)
            NSLog(@"Error while   getDiscussionReply statement. %s for forumId = %@", sqlite3_errmsg(db), discussionId);
        
        NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:8];
        while  (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            [result addObject:[self parseDiscussionReply:statement]];
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
        return result;
    }

}

@end
