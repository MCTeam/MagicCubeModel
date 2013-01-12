//
//  MCKnowledgeBase.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCKnowledgeBase.h"


@implementation MCKnowledgeBase

+ (MCKnowledgeBase *)getSharedKnowledgeBase{
    static MCKnowledgeBase *knowledgeBase;
    @synchronized(self)
    {
        if (!knowledgeBase)
            knowledgeBase = [[MCKnowledgeBase alloc] init];
        return knowledgeBase;
    }
}

- (id)init{
    if(self = [super init]){
        sqlite3 *database;
        if (sqlite3_open([[self knowledgeBaseFilePath] UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            NSLog(@"Failed to open database.");
        }
        else{
            char *errorMsg;
            //create the pattern table if not exist
            NSString *createPatternSQL = @"CREATE TABLE IF NOT EXISTS PATTERNS (KEY TEXT NOT NULL UNIQUE, PATTERN TEXT NOT NULL);";
            if (sqlite3_exec(database, [createPatternSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(database);
                NSLog(@"error creating table: %s", errorMsg);
            }
            //create the rule table if not exist
            NSString *createRuleSQL = @"CREATE TABLE IF NOT EXISTS RULES(MEHOD INTEGER NOT NULL, RULE_IF TEXT NOT NULL, RULE_THEN TEXT NOT NULL);";
            if (sqlite3_exec(database, [createRuleSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(database);
                NSLog(@"error creating table: %s", errorMsg);
            }
        }
    }
    return self;
}

- (NSString *)knowledgeBaseFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:KNOWLEDGE_DB_FILE_NAME];
}

- (BOOL)insertPattern:(NSString *)pattern withKey:(NSString *)key{
    sqlite3 *database;
    if (sqlite3_open([[self knowledgeBaseFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database.");
        return NO;
    }
    else{
        char *insertPattern = "INSERT OR REPLACE INTO PATTERNS (KEY, PATTERN) VALUES (?, ?);";
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(database, insertPattern, -1, &stmt, nil) == SQLITE_OK){
            sqlite3_bind_text(stmt, 1, [key UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [pattern UTF8String], -1, NULL);
        }
        else{
            NSLog(@"Failed to prepare insert stmt.");
            return NO;
        }
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Failed to insert pattern.");
            return NO;
        }
        
        sqlite3_finalize(stmt);
    }
    sqlite3_close(database);
    return YES;
}

- (BOOL)insertRullOfMethod:(NSInteger)method ifContent:(NSString *)ifContent thenContent:(NSString *)thenContent{
    sqlite3 *database;
    if (sqlite3_open([[self knowledgeBaseFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database.");
        return NO;
    }
    else{
        char *insertRule = "INSERT OR REPLACE INTO RULES (MEHOD, RULE_IF, RULE_THEN) VALUES (?, ?, ?);";
        sqlite3_stmt *stmt;
        if(sqlite3_prepare_v2(database, insertRule, -1, &stmt, nil) == SQLITE_OK){
            sqlite3_bind_int(stmt, 1, method);
            sqlite3_bind_text(stmt, 2, [ifContent UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [thenContent UTF8String], -1, NULL);
        }
        else{
            NSLog(@"Failed to prepare insert stmt.");
            return NO;
        }
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Failed to insert pattern.");
            return NO;
        }
        
        sqlite3_finalize(stmt);
    }
    sqlite3_close(database);
    return YES;
}

- (NSMutableDictionary *)getPatterns{
    sqlite3 *database;
    if (sqlite3_open([[self knowledgeBaseFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database.");
        return nil;
    }
    else{
        NSMutableDictionary *patterns = [NSMutableDictionary dictionaryWithCapacity:PATTERN_NUM];
        NSString *patternQuery = @"SELECT KEY, PATTERN FROM PATTERNS";
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, [patternQuery UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *key = (char *)sqlite3_column_text(stmt, 0);
                char *pattern = (char *)sqlite3_column_text(stmt, 1);
                
                NSString *patternName = [[NSString alloc] initWithUTF8String:key];
                NSString *patternStr = [[NSString alloc] initWithUTF8String:pattern];
                MCPattern *mcPattern = [[MCPattern alloc] initWithString:patternStr];
                [patterns setObject:mcPattern forKey:patternName];
                [patternName release];
                [patternStr release];
                [mcPattern release];
            }
        }
        return patterns;
    }
}

@end
