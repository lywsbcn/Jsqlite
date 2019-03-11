//
//  Jsql.m
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//

#import "Jsqlite.h"
#import "YYModel.h"

#ifndef NDEBUG
#define SLog(message, ...) printf("%s\n", [[NSString stringWithFormat:message, ##__VA_ARGS__] UTF8String])
#else
#define SLog(message, ...)
#endif

NSString * const JSQL_JOINT_AND = @"AND";
NSString * const JSQL_JOINT_OR  = @"OR";
NSString * const JSQL_JOINT_LIKE= @"LIKE";
NSString * const JSQL_JOINT_NOT_LIKE=@"NOT LIKE";
static Jsqlite * jsqliteManager = nil;
@interface Jsqlite()
@property(nonatomic,assign)BOOL showLog;
@property(nonatomic,copy)NSString * tableName;
@property(nonatomic,copy)NSMutableString * whereStr;
@property(nonatomic,copy)NSString * fieldStr;
@property(nonatomic,copy)NSString * limitStr;
@property(nonatomic,copy)NSString * orderStr;
@property(nonatomic,copy)NSString * groupStr;

@property(nonatomic,assign)Class  cName;
@end

@implementation Jsqlite
+(instancetype)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsqliteManager =[self create];
        
    });
    return jsqliteManager;
}
+(instancetype)create{
    return [[self alloc]init];
}
-(void)reset{
    [self.whereStr setString:@""];
    self.fieldStr= @"";
    self.limitStr = @"";
    self.orderStr=@"";
    self.groupStr=@"";
    self.cName = nil;
    self.tableName = @"";
}

-(instancetype)init{
    if(self =[super init]){
        _conn =[JSQLconn instance];
        _showLog = YES;
        self.limitStr= @"";
        self.orderStr=@"";
        self.groupStr=@"";
        
        [self initation];
    }
    return self;
}

-(void)initation{
    __weak typeof(self) wself = self;
    
    _select = ^NSArray *{
        if(wself.tableName.length ==0){
            SLog(@"请设置表名");
            return nil;
        }
        NSMutableString * sql = [NSMutableString stringWithString:@"SELECT "];
        
        if(wself.fieldStr.length==0){
            [sql appendString:@"* "];
        }else{
            [sql appendFormat:@"%@ ",wself.fieldStr];
        }
        
        [sql appendFormat:@"FROM %@ ",wself.tableName];
        
        if(wself.whereStr.length>0){
            [sql appendFormat:@"%@ ",wself.whereStr];
        }
        
        if(wself.groupStr.length>0){
            [sql appendFormat:@"%@ ",wself.groupStr];
        }
        
        if(wself.orderStr.length>0){
            [sql appendFormat:@"%@ ",wself.orderStr];
        }
        
        if(wself.limitStr.length>0){
            [sql appendFormat:@"%@",wself.limitStr];
        }
        
        wself.SQL = sql;
        
        if(wself.showLog) SLog(@"%@",sql);
        Class cname = wself.cName;
        [wself reset];
        if(cname) return [wself.conn querySQL:sql WithClass:cname];
        return [wself.conn querySQL:sql];
    };
    
    _find = ^id{
        wself.limit(1);
        return wself.select().firstObject;
    };
    
    _count = ^NSInteger{
        wself.fieldStr=@"count(1)";
        wself.limit(1);
        
        return [[wself.select().firstObject objectForKey:@"count(1)"] integerValue];
    };
    
    _className = ^Jsqlite *(Class name) {
        wself.cName = name;
        return wself;
    };
    _exists = ^BOOL{
        return wself.count() >0;
    };
    
    _insertAll = ^NSInteger(NSArray *data){
        if(wself.tableName.length ==0){
            SLog(@"请设置表名");
            return 0;
        }
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",wself.tableName];
        
        NSMutableString * fields=[NSMutableString string];
        NSMutableString * values=[NSMutableString string];
        
        for(id model in data){
            NSMutableString * value=[NSMutableString string];
            BOOL first = model == data.firstObject;
            
            NSDictionary * m;
            if([model isKindOfClass:[NSDictionary class]]){
                m = model;
            }else{
                m = [model yy_modelToJSONObject];
            }
            
            for(id key in m){
                if(first){
                    if(fields.length==0) [fields appendFormat:@"'%@'",key];
                    else [fields appendFormat:@",'%@'",key];
                }
                if(value.length==0) [value appendFormat:@"'%@'",[m objectForKey:key]];
                else [value appendFormat:@",'%@'",[m objectForKey:key]];
            }
            if(values.length==0) [values appendFormat:@"(%@)",value];
            else [values appendFormat:@",(%@)",value];
        }
        
        [sql appendFormat:@"(%@) VALUES %@",fields,values];
        
        wself.SQL = sql;
        
        if(wself.showLog) SLog(@"%@",sql);
        [wself reset];
        if([wself.conn execuSQL:sql]){
            return [wself.conn changes];
        }
        
        return 0;
    };
    
    _insert = ^NSInteger(id data){
        
        if(data && wself.insertAll(@[data])){
            return [wself.conn getID];
        }
        
        return 0;
    };
    
    _update = ^NSInteger(NSDictionary * data){
        if(wself.tableName.length ==0){
            SLog(@"请设置表名");
            return 0;
        }
        if(wself.whereStr.length==0){
            SLog(@"请设置条件");
            return 0;
        }
        NSMutableString * sql =[NSMutableString stringWithFormat:@"UPDATE %@ SET ",wself.tableName];
        NSMutableString * fields =[NSMutableString string];
        for(id key in data){
            if(fields.length==0) [fields appendFormat:@"'%@'='%@'",key,[data objectForKey:key]];
            else [fields appendFormat:@",'%@'='%@'",key,[data objectForKey:key]];
        }
        [sql appendFormat:@"%@ ",fields];
        [sql appendFormat:@"%@ ",wself.whereStr];
        
        wself.SQL = sql;
        
        if(wself.showLog) SLog(@"%@",sql);
        [wself reset];
        if([wself.conn execuSQL:sql]){
            return [wself.conn changes];
        }
        
        return 0;
    };
    
    _del = ^NSInteger{
        if(wself.tableName.length ==0){
            SLog(@"请设置表名");
            return 0;
        }
        if(wself.whereStr.length==0){
            SLog(@"请设置条件");
            return 0;
        }
        NSMutableString * sql =[NSMutableString stringWithFormat:@"DELETE FROM %@ ",wself.tableName];
        [sql appendFormat:@"%@ ",wself.whereStr];
        
        wself.SQL= sql;
        
        if(wself.showLog) SLog(@"%@",sql);
        [wself reset];
        if([wself.conn execuSQL:sql]){
            return [wself.conn changes];
        }
        
        return 0;
    };
    
    
    
#pragma mark - sql 拼接
    
    _table = ^Jsqlite*(NSString * tablename){
        wself.tableName = tablename;
        return wself;
    };
    
    _where = ^Jsqlite *(NSString *condition, ...) {
        
        va_list args;
        va_start(args, condition);
        NSString * sql = [[NSString alloc]initWithFormat:condition arguments:args];
        va_end(args);
        
        [wself conditonWithJoint:JSQL_JOINT_AND AndSQL:sql];
        
        return wself;
    };
    
    _orwhere = ^Jsqlite *(NSString *condition, ...) {
        va_list args;
        va_start(args, condition);
        NSString * sql = [[NSString alloc]initWithFormat:condition arguments:args];
        va_end(args);
        
        [wself conditonWithJoint:JSQL_JOINT_OR AndSQL:sql];
        
        return wself;
    };
    
    _field = ^Jsqlite *(NSString *field) {
        wself.fieldStr = field;
        return wself;
    };
    
    _limit = ^Jsqlite *(NSInteger size) {
    
        wself.limitStr = [NSString stringWithFormat:@"LIMIT %ld",size];
        
        return wself;
    };
    
    _limit_two = ^Jsqlite *(NSInteger index, NSInteger size) {
        wself.limitStr =[NSString stringWithFormat:@"LIMIT %ld,%ld",index*size,size];
        return wself;
    };
    
    _order = ^Jsqlite *(NSString *order) {
        wself.orderStr =[NSString stringWithFormat:@"ORDER BY %@",order];
        return wself;
    };
    
    _group = ^Jsqlite *(NSString *group) {
        wself.groupStr=[NSString stringWithFormat:@"GROUP BY %@",group];
        return wself;
    };
    
    

    
}

-(void)conditonWithJoint:(NSString*)Joint AndSQL:(NSString*)sql{
    
    if(self.whereStr.length ==0){
        [self.whereStr appendFormat:@"WHERE ( %@ ) ",sql];
    }else{
        [self.whereStr appendFormat:@"%@ (%@) ",Joint,sql];
    }
    
}



-(NSMutableString *)whereStr{
    if(!_whereStr){
        _whereStr=[NSMutableString string];
    }
    return _whereStr;
}


@end
