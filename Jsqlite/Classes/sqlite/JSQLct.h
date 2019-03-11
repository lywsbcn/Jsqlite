//
//  JsqCreateTable.h
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//

/*
    sqlite 创建表
 */

#import <Foundation/Foundation.h>
#import "JSQLconn.h"


//数据类型
extern NSString * const JSQCT_INTEGER;
extern NSString * const JSQCT_TEXT;
extern NSString * const JSQCT_REAL;
extern NSString * const JSQCT_BLOB;

//字段属性
extern NSString * const JSQCT_PRIMARY;
extern NSString * const JSQCT_AUTOINCREMENT;
extern NSString * const JSQCT_NOTNULL;

@interface JSQLct : NSObject

/*默认 单例*/
+(instancetype)instance;

/*创建一个新的实例*/
+(instancetype)create;

/*
    sqlite 连接对象
    默认为 [JSQLconn instance]
 */
@property(nonatomic,strong)JSQLconn * conn;

/*设置要添加的表名*/
@property(nonatomic,copy,readonly)JSQLct*(^table)(NSString * name);

/*
    设置字段
    @param name NSString 字段名
    @param type NSString 数据类型
    @param NotNull BOOL  是否可以为空
    @param PRIMARY BOOL  是否为主键
    @param AUTOINCREMENT BOOL 是否自增
 */
@property(nonatomic,copy,readonly)JSQLct*(^field)(NSString * name,NSString * type , BOOL NotNull ,BOOL PRIMARY,BOOL AUTOINCREMENT);

/*设置主键字段
 NotNull = YES
 PRIMARY = YES
 AUTOINCREMENT = YES
 */
@property(nonatomic,copy,readonly)JSQLct*(^primary)(NSString * name);

/*
 设置 interger 类型字段
 */
@property(nonatomic,copy,readonly)JSQLct *(^integer)(NSString * name);

/*
    设置 text 类型字段
 */
@property(nonatomic,copy,readonly)JSQLct *(^text)(NSString * name);

/*
    根据 map 创建字段
 范例1:
    @{
         @"user":@{
             @"id":JSQCT_PRIMARY,
             @"user_id":JSQCT_INTEGER,
             @"username":JSQCT_TEXT,
             @"token":JSQCT_TEXT,
             @"logintime":JSQCT_INTEGER
         }
     };
 范例2:
     @{
         @"user":@{
             @"id":@["INTEGER","PRIMARY KEY"],
     }
     };
 
 */
@property(nonatomic,copy,readonly)void(^column)(NSDictionary *data);
/*
    根据map 创建表格和字段
    范例: 同上
 */
@property(nonatomic,copy,readonly)void(^list)(NSDictionary*data);

/*
 执行创建表操作
 完成后重置数据
 */
@property(nonatomic,copy,readonly)void(^done)(void);

/*生成的 sql 语句*/
@property(nonatomic,copy,readonly)NSString * SQL;

@end

