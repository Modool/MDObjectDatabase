# MDObjectDatabase

[![](https://img.shields.io/travis/rust-lang/rust.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/language-Object--C-1eafeb.svg?style=flat)](https://developer.apple.com/Objective-C)
[![](https://img.shields.io/badge/license-MIT-353535.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/QQ群-662988771-red.svg)](http://wpa.qq.com/msgrd?v=3&uin=662988771&site=qq&menu=yes)

## Introduction

- Database processing with object without SQL.

## How To Get Started

* Download `MDObjectDatabase ` and try run example app

## Installation


* Installation with CocoaPods

```
source 'https://github.com/Modool/cocoapods-specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'MDObjectDatabase', '~> 1.0.0'
end

```

* Installation with Carthage

```
github "Modool/MDObjectDatabase" ~> 1.0.0
```

* Manual Import

```
drag “MDObjectDatabase” directory into your project

```


## Requirements
- Requires ARC
- Depend on FMDB

## Architecture

### Database

* `MDDatabaseCenter` To distribute Database.

* `MDDatabase` To manage FMDB queue, table infos, configuratinos, compats and process SQL.
* `MDDConfiguration` Object configuration contained properties mapper, indexes and database key parameters.
* `MDDCompat` To request an compat permission from outside for table column or index differences. 
* `MDDColumnConfiguration` Configuration of database column.
* `MDDTableInfo ` To manage properties of class and columns, indexes of database.
* `MDDColumn ` Database column info contained key parameters.
* `MDDIndex ` Database indexes info.

### Accessor

* `MDDAccessor` To process database operation with MDDProcessor instance in dispatch queue, support to asynchronize and synchronize.

* `MDDatabase+MDDAccessor` To request an accessor from database.
* `MDDProcessor` Normal database operation, such as query, delete, insert, update, and so on.
* `MDDCoreProcessor` The core processor for processing SQL 

### Descriptor

* `MDDDescriptor` The base class to describe property.
	* `MDDCondition` Descriptor of database condition, to describe the relationship between key and value.

	* `MDDConditionSet` Descriptor of multiple database conditions, support to nest with set.
	* `MDDCondition+MDDConditionSet` Condition operations.
	* `MDDSetter` Descriptor of database updating setter item, like`key1=value1`,`key2=value2` and full description like`SET key1=value1, key2=value2`.
	* `MDDInsertSetter` Descriptor of database inserting setter item, full description like`(key1, key2, key3) VALUES(value1, value2, value3)`.
	* `MDDSort` Descriptor of database sort item, like`key1 ASC`, sometime maybe multiple sorts like`key1 ASC, key2 DESC`.
	* `MDDQuery` Descriptor of database QUERY with keys, conditions and sorts, like`SELECT keys WHERE conditions ORDER BY sorts LIMIT range`.
	* `MDDUpdater` Descriptor of database UPDATE with setters and conditions, like`UPDATE SET key1=value1, key2=value2 WHERE conditions`.
	* `MDDInserter` Descriptor of database INSERT with insert-setters and conditions, like`INSERT INTO (keys) VALUES(values) WHERE conditions`.
	* `MDDDeleter ` Descriptor of database DELETE with conditions, like`DELETE FROM table_name WHERE conditions`.
	* `MDDFunctionQuery ` Descriptor of database FUNCTION(such as SUM, MAX, MIN, COUNT, AVERAGE) with conditions, like`SELECT function(key) AS alias FROM table_name WHERE conditions`.


### Token Description

* `MDDTokenDescription ` Description with values and SQL using `?` to replace value.
	
## Usage

* Demo FYI 

## Update History

* 2017.7.30 Add README and adjust project class name.

## License
`MDDatabase ` is released under the MIT license. See LICENSE for details.

## Article

Article support if you want to see more extension or demo. <a href=https://github.com/Modool/MDDatabase/blob/master/MDDatabase.md>Go</a>.

## Communication

<img src="https://github.com/Modool/Resources/blob/master/images/social/qq_300.png?raw=true" width=200><img style="margin:0px 50px 0px 50px" src="https://github.com/Modool/Resources/blob/master/images/social/wechat_300.png?raw=true" width=200><img src="https://github.com/Modool/Resources/blob/master/images/social/github_300.png?raw=true" width=200>