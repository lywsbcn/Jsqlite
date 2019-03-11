//
//  Jsqlite.m
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//

#import "JSQLconn.h"
#import <sqlite3.h>
#import "YYModel.h"
static JSQLconn * jsqliteManger = nil;
@interface JSQLconn()

@property (nonatomic,assign) sqlite3 *db;

@end

@implementation JSQLconn

+(instancetype)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsqliteManger = [[JSQLconn alloc]init];
        jsqliteManger.dbName = @"appSqlite.sqlite";
    });
    return jsqliteManger;
}

-(BOOL)openDB{
    NSString * document =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * path = [document stringByAppendingPathComponent:_dbName];
    NSLog(@"%@",path);
    if(sqlite3_open(path.UTF8String, &_db) != SQLITE_OK){
        NSLog(@"连接数据库 %@ 失败!!",self.dbName);
        return NO;
    }
    NSLog(@"连接数据库 %@ 成功!!",self.dbName);
    return YES;
}

-(void)closeDB{
    sqlite3_close(self.db);
}

-(NSInteger)getID{
    return sqlite3_last_insert_rowid(self.db);
}

-(NSInteger)changes{
    return sqlite3_changes(self.db);
}
-(BOOL)creatTableExecSQL:(NSArray *)SQL_ARR{
    for (NSString *SQL in SQL_ARR) {
        if (![self execuSQL:SQL]) {
            return NO;
        }
    }
    return YES;
}

#pragma 执行SQL语句
- (BOOL)execuSQL:(NSString *)SQL{
    
    char *error;
    //参数一:数据库对象  参数二:需要执行的SQL语句  其余参数不需要处理
    if (sqlite3_exec(self.db, SQL.UTF8String, nil, nil, &error) == SQLITE_OK) {
        return YES;
    }else{
        NSLog(@"SQLiteManager执行SQL语句出错:%s",error);
        return NO;
    }
}

#pragma mark - 查询数据库中数据
-(NSArray *)querySQL:(NSString *)SQL WithClass:(Class)name{
    //准备查询
    // 1> 参数一:数据库对象
    // 2> 参数二:查询语句
    // 3> 参数三:查询语句的长度:-1
    // 4> 参数四:句柄(游标对象)
    
    sqlite3_stmt *stmt = nil;
    if (sqlite3_prepare_v2(self.db, SQL.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
        NSLog(@"准备查询失败!");
        return NULL;
    }
    //准备成功,开始查询数据
    //定义一个存放数据字典的可变数组
    NSMutableArray *dictArrM = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //一共获取表中所有列数(字段数)
        int columnCount = sqlite3_column_count(stmt);
        //定义存放字段数据的字典
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < columnCount; i++) {
            // 取出i位置列的字段名,作为字典的键key
            const char *cKey = sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithUTF8String:cKey];
            
            //取出i位置存储的值,作为字典的值value
            const char *cValue = (const char *)sqlite3_column_text(stmt, i);
            NSString * value;
            if(cValue == NULL){
                value = @"";
            }else{
                value = [NSString stringWithUTF8String:cValue];
            }
            
            //将此行数据 中此字段中key和value包装成 字典
            [dict setObject:value forKey:key];
        }
        [dictArrM addObject:[name yy_modelWithJSON:dict]];
    }
    return dictArrM;
}

-(NSArray *)querySQL:(NSString *)SQL{
    //准备查询
    // 1> 参数一:数据库对象
    // 2> 参数二:查询语句
    // 3> 参数三:查询语句的长度:-1
    // 4> 参数四:句柄(游标对象)
    
    sqlite3_stmt *stmt = nil;
    if (sqlite3_prepare_v2(self.db, SQL.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
        NSLog(@"准备查询失败!");
        return NULL;
    }
    //准备成功,开始查询数据
    //定义一个存放数据字典的可变数组
    NSMutableArray *dictArrM = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //一共获取表中所有列数(字段数)
        int columnCount = sqlite3_column_count(stmt);
        //定义存放字段数据的字典
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < columnCount; i++) {
            // 取出i位置列的字段名,作为字典的键key
            const char *cKey = sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithUTF8String:cKey];
            
            //取出i位置存储的值,作为字典的值value
            const char *cValue = (const char *)sqlite3_column_text(stmt, i);
            NSString * value;
            if(cValue == NULL){
                value = @"";
            }else{
                value = [NSString stringWithUTF8String:cValue];
            }
            
            //将此行数据 中此字段中key和value包装成 字典
            [dict setObject:value forKey:key];
        }
        [dictArrM addObject:dict];
    }
    return dictArrM;
}
@end
