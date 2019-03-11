//
//  Jsql.h
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//
/*
 核心部分
 sql helper
 */

#import <Foundation/Foundation.h>
#import "JSQLconn.h"
#import "JSQLct.h"

/*条件拼接常量*/
extern NSString * const JSQL_JOINT_AND ;
extern NSString * const JSQL_JOINT_OR ;
extern NSString * const JSQL_JOINT_LIKE;
extern NSString * const JSQL_JOINT_NOT_LIKE;

@interface Jsqlite : NSObject
/*单例*/
+(instancetype)instance;
/*快速创建*/
+(instancetype)create;
/*数据库连接对象*/
@property(nonatomic,strong)JSQLconn * conn;

/*根据条件获取列表*/
@property(nonatomic,copy,readonly)NSArray *(^select)(void);

/*获取一条数据,哪怕符合条件的记录有多条
 LIMIT 1
 */
@property(nonatomic,copy,readonly)id(^find)(void);

/*一次性插入多条数据*/
@property(nonatomic,copy,readonly)NSInteger(^insertAll)(NSArray *data);

/*添加一条数据 返回插入数据的id*/
@property(nonatomic,copy,readonly)NSInteger(^insert)(id data);

/*根据数据*/
@property(nonatomic,copy,readonly)NSInteger(^update)(NSDictionary* data);

/*删除记录*/
@property(nonatomic,copy,readonly)NSInteger(^del)(void);

/*数据数量*/
@property(nonatomic,copy,readonly)NSInteger(^count)(void);

@property(nonatomic,copy,readonly)BOOL(^exists)(void);

/*sql 拼接*/

@property(nonatomic,copy,readonly)Jsqlite*(^className)(Class name);
/*设置查询的表名*/
@property(nonatomic,copy,readonly)Jsqlite*(^table)(NSString * tablename);

/*where 条件
 where(@"'username'='%@'",@"132");
 */
@property(nonatomic,copy,readonly)Jsqlite*(^where)(NSString * condition ,...);

/*or where 条件*/
@property(nonatomic,copy,readonly)Jsqlite*(^orwhere)(NSString * condition ,...);

/*筛选的字段*/
@property(nonatomic,copy,readonly)Jsqlite*(^field)(NSString*field);

/*限制条数*/
@property(nonatomic,copy,readonly)Jsqlite *(^limit)(NSInteger size);
/*
 限制条数和偏移
 内部已经计算 (index*size,size)
 */
@property(nonatomic,copy,readonly)Jsqlite*(^limit_two)(NSInteger index,NSInteger size);

/*排序*/
@property(nonatomic,copy,readonly)Jsqlite*(^order)(NSString * order);

/*分组*/
@property(nonatomic,copy,readonly)Jsqlite *(^group)(NSString*group);

/*sql 语句*/
@property(nonatomic,copy)NSString *SQL;


@end
