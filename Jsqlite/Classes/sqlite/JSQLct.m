//
//  JsqCreateTable.m
//  QRReader
//
//  Created by w on 2019/1/31.
//  Copyright © 2019年 w. All rights reserved.
//

#import "JSQLct.h"
NSString * const JSQCT_INTEGER = @"INTEGER";
NSString * const JSQCT_TEXT =    @"TEXT";
NSString * const JSQCT_REAL =    @"REAL";
NSString * const JSQCT_BLOB=     @"BLOB";
NSString * const JSQCT_PRIMARY = @"PRIMARY KEY";
NSString * const JSQCT_AUTOINCREMENT=@"AUTOINCREMENT";
NSString * const JSQCT_NOTNULL= @"NOT NULL";


@interface JSQLctM :NSObject

@property(nonatomic,copy)NSString * type;
@property(nonatomic,copy)NSString * strings;

@end
@implementation JSQLctM
@end


static JSQLct * jsqlctManager = nil;
@interface JSQLct()

@property(nonatomic,copy)JSQLct*(^withModel)(NSString * name,JSQLctM * model);

@property(nonatomic,copy)NSString * tableName;

@property(nonatomic,strong)NSMutableDictionary * dict;

@end

@implementation JSQLct

+(instancetype)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsqlctManager = [self create];
    });
    return jsqlctManager;
}

+(instancetype)create{
    return [[self alloc]init];
}

-(instancetype)init{
    if(self =[super init]){
        self.conn = [JSQLconn instance];
        [self initation];
    }
    return self;
}

-(void)initation{
    __weak typeof(self) wself = self;
    _table = ^JSQLct *(NSString *name) {
        wself.tableName = name;
        return wself;
    };
    
    _withModel=^JSQLct *(NSString * name,JSQLctM * model){
        [wself.dict setObject:model forKey:name];
        return wself;
    };
    
    _field = ^JSQLct *(NSString *name, NSString *type ,BOOL NotNull, BOOL PRIMARY,BOOL AUTOINCREMENT) {
        JSQLctM * m = [[JSQLctM alloc]init];
        
        NSMutableString * str =[NSMutableString string];
        [str appendString:type];
        
        if(NotNull){
            [str appendFormat:@" %@",JSQCT_NOTNULL];
        }
        if(PRIMARY){
            [str appendFormat:@" %@",JSQCT_PRIMARY];
        }
        if(AUTOINCREMENT){
            [str appendFormat:@" %@",JSQCT_AUTOINCREMENT];
        }
        m.strings = str;
        return wself.withModel(name,m);
    };
    
    _primary = ^JSQLct *(NSString *name) {
        return wself.field(name,JSQCT_INTEGER,YES,YES,YES);
    };
    
    _integer = ^JSQLct *(NSString *name) {
        return wself.field(name,JSQCT_INTEGER,NO,NO,NO);
    };
    
    _text = ^JSQLct *(NSString *name) {
        return wself.field(name,JSQCT_TEXT,NO,NO,NO);
    };
    
    _column=^(NSDictionary *data){
      
        for(NSString * name in data){
            id  type = [data objectForKey:name];
            if([type isKindOfClass:[NSString class]]){
                if([type isEqualToString:JSQCT_PRIMARY]){
                    wself.primary(name);
                }else if ([type isEqualToString:JSQCT_TEXT]){
                    wself.text(name);
                }else if([type isEqualToString:JSQCT_INTEGER]){
                    wself.integer(name);
                }else if ([type isEqualToString:JSQCT_BLOB]){
                    wself.field(name, JSQCT_BLOB, NO, NO, NO);
                }else if ([type isEqualToString:JSQCT_REAL]){
                    wself.field(name, JSQCT_REAL, NO, NO, NO);
                }
            }else if ([type isKindOfClass:[NSArray class]]){
                if(((NSArray*)type).count >0){
                    JSQLctM * model =[[JSQLctM alloc]init];
                    model.strings = [type componentsJoinedByString:@" "];
                    wself.withModel(name, model);
                }
            }
        }
        
        wself.done();
        
    };
    
    _list =^(NSDictionary * data){
        for(NSString * tablename in data){
            wself.table(tablename).column([data objectForKey:tablename]);
        }
    };
    
    _done=^{
        if(wself.tableName.length==0){
            NSLog(@"请设置表名");
            return ;
        }
        if(wself.dict.allKeys.count==0){
            NSLog(@"请设置字段");
            return;
        }
        
        [wself.conn execuSQL:wself.SQL];
        
        
        wself.tableName= @"";
        [wself.dict removeAllObjects];
    };
    
    
    
}

-(NSString *)SQL{
    NSMutableString * sql=[NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS "];
    [sql appendFormat:@"\"%@\" ( ",self.tableName];
    
    NSMutableString * field=[NSMutableString string];
    for(NSString * key in self.dict){
        JSQLctM * m = [self.dict objectForKey:key];

        if(field.length>0){
            [field appendString:@","];
        }
        
        [field appendFormat:@"\"%@\" %@ ",key,m.strings];
        
    }
    [sql appendString:field];
    
    [sql appendString:@");"];
    
    NSLog(@"%@",sql);
    return sql;
}

-(NSMutableDictionary *)dict{
    if(!_dict){
        _dict =[NSMutableDictionary dictionary];
    }
    return _dict;
}



@end
