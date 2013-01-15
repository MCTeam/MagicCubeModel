//
//  MCKnowledgeBase.h
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#include "MCBasicElement.h"

#define KNOWLEDGE_DB_FILE_NAME @"KnowledgeBase.sqlite3"
#define PATTERN_NUM 30

@interface MCKnowledgeBase : NSObject

+ (MCKnowledgeBase *)getSharedKnowledgeBase;

- (NSString *)knowledgeBaseFilePath;

- (BOOL)insertPattern:(NSString *)pattern withKey:(NSString *)key withPreState:(NSString *)state;

- (BOOL)insertRullOfMethod:(NSInteger)method ifContent:(NSString *)ifContent thenContent:(NSString *)thenContent;

- (BOOL)insertStateWithPattern:(NSString *)pattern withPreState:(NSString *)preState afterState:(NSString *)afterState;

- (NSMutableDictionary *)getPatternsWithPreState:(NSString *)state;

- (NSMutableDictionary *)getStates;

- (NSMutableDictionary *)getRules;

@end
