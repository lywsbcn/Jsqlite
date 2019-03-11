//
//  Jsqlite.h
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//

/*
 sqlite 连接管理
 基本操作
 */

#import <Foundation/Foundation.h>

@interface JSQLconn : NSObject
/*单例*/
+(instancetype)instance;
/*数据库名称
 默认为 appSqlite.sqlite
 位置 沙盒/Documents/appSqlite.sqlite
 */
@property(nonatomic,copy)NSString * dbName;

/*
 打开数据库
 如果数据库存在就打开,如果不存在就创建一个再打开
 */
-(BOOL)openDB;

/*关闭数据库*/
-(void)closeDB;

/*批量创建表*/
-(BOOL)creatTableExecSQL:(NSArray <NSString*>*)SQL_ARR;

/*执行 sql 语句*/
- (BOOL)execuSQL:(NSString *)SQL;

/*查询数据库中数据*/
-(NSArray *)querySQL:(NSString *)SQL WithClass:(Class)name;
-(NSArray *)querySQL:(NSString *)SQL;

/*获取插入数据后的id*/
-(NSInteger)getID;

/*获取受影响的记录数
 增,改,删
 */
-(NSInteger)changes;


@end
