# Jsqlite

[![CI Status](https://img.shields.io/travis/lywsbcn/Jsqlite.svg?style=flat)](https://travis-ci.org/lywsbcn/Jsqlite)
[![Version](https://img.shields.io/cocoapods/v/Jsqlite.svg?style=flat)](https://cocoapods.org/pods/Jsqlite)
[![License](https://img.shields.io/cocoapods/l/Jsqlite.svg?style=flat)](https://cocoapods.org/pods/Jsqlite)
[![Platform](https://img.shields.io/cocoapods/p/Jsqlite.svg?style=flat)](https://cocoapods.org/pods/Jsqlite)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Jsqlite is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Jsqlite'
```

## use
# JSQLct
创建表格

根据 map 创建字段
 
 范例1: 
```ruby 
    @{
         @"id":JSQCT_PRIMARY,
         @"user_id":JSQCT_INTEGER,
         @"username":JSQCT_TEXT,
         @"token":JSQCT_TEXT,
         @"logintime":JSQCT_INTEGER
     }
```
 范例2:
```ruby
     @{
           @"id":@["INTEGER","PRIMARY KEY"],            
     };
[JSQLct instance].table(NSString *name).column(NSDictionary *data);
```
同时创建多张表

范例1:
```ruby
    @{
         @"user":@{
             @"id":JSQCT_PRIMARY,
             @"user_id":JSQCT_INTEGER,
             @"username":JSQCT_TEXT,
             @"token":JSQCT_TEXT,
             @"logintime":JSQCT_INTEGER
         }
     }
```
 范例2:
```ruby
     @{
         @"user":@{
             @"id":@["INTEGER","PRIMARY KEY"],
            }
     };

[JSQLct instance].list(NSDictionary *data);
```
内部实现
```ruby
for(NSString * tablename in data){
    wself.table(tablename).column([data objectForKey:tablename]);
}
```

# Jsqlite
查询列表,返回一个数组
```ruby
NSArray * arr =[Jsqlite instance].table("user").select();
```
返回Class 数组
```ruby
NSArray * arr =[Jsqlite instance].table("user").className(Class name).select();
```
条件查询
```ruby
[Jsqlite instance].table("user").where("id=%ld",userid).select();
```
筛选的字段
```ruby
[Jsqlite instance].table("user").where("id=%ld",userid).field("id,username,createtime").select();
```
排序
```ruby
[Jsqlite instance].table("user").field("id,username,createtime").order("createtime desc").select();
```
分页
```ruby
[Jsqlite instance].table("user").limit(10).select();


[Jsqlite instance].table("user").limit_two(0,10).select();
```
获取一条数据
```ruby
NSDictionary * data = [Jsqlite instance].table("user").find();
```
添加一条数据 返回插入数据的id
```ruby
NSInteget id = [Jsqlite instance].table("user").insert(id data);
```
一次性插入多条数据
```ruby
NSInteget changes = [Jsqlite instance].table("user").insertAll(NSArray* data);
```
更新数据
```ruby
NSInteget changes = [Jsqlite instance].table("user").update(NSDictionary* data);

删除记录
NSInteget changes = [Jsqlite instance].table("user").where("id>0").del();
```
数据数量
```ruby
NSInteget count = [Jsqlite instance].table("user").count();
```
记录是否存在
```ruby
BOOL exsits = [Jsqlite instance].table("user").where("id=%ld",id).exists();
```
## Author

lywsbcn, 89324055@qq.com

## License

Jsqlite is available under the MIT license. See the LICENSE file for more info.
