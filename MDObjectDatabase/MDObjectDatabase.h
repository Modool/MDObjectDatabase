//
//  MDDatabaseUmbrella.h
//  MDDatabase
//
//  Created by xulinfeng on 2018/3/23.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MDObjectDatabase.
FOUNDATION_EXPORT double MDObjectDatabaseVersionNumber;

//! Project version string for MDObjectDatabase.
FOUNDATION_EXPORT const unsigned char MDObjectDatabaseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MDObjectDatabase/PublicHeader.h>

// Accessor
#import <MDObjectDatabase/MDDConstants.h>
#import <MDObjectDatabase/MDDAccessor.h>
#import <MDObjectDatabase/MDDatabase+MDDAccessor.h>
#import <MDObjectDatabase/MDDProcessor.h>
#import <MDObjectDatabase/MDDDescriptor.h>
#import <MDObjectDatabase/MDDKeyValueDescriptor.h>
#import <MDObjectDatabase/MDDCondition.h>
#import <MDObjectDatabase/MDDConditionSet.h>
#import <MDObjectDatabase/MDDCondition+MDDConditionSet.h>
#import <MDObjectDatabase/MDDSetter.h>
#import <MDObjectDatabase/MDDInsertSetter.h>
#import <MDObjectDatabase/MDDSort.h>
#import <MDObjectDatabase/MDDUpdater.h>
#import <MDObjectDatabase/MDDInserter.h>
#import <MDObjectDatabase/MDDDeleter.h>
#import <MDObjectDatabase/MDDQuery.h>
#import <MDObjectDatabase/MDDFunctionQuery.h>
#import <MDObjectDatabase/MDDDescription.h>
#import <MDObjectDatabase/MDDIndex.h>

// Database
#import <MDObjectDatabase/MDDRange.h>
#import <MDObjectDatabase/MDDObject.h>
#import <MDObjectDatabase/MDDatabase.h>
#import <MDObjectDatabase/MDDatabaseCenter.h>
#import <MDObjectDatabase/MDDColumnConfiguration.h>
#import <MDObjectDatabase/MDDTableInfo.h>
#import <MDObjectDatabase/MDDColumn.h>
#import <MDObjectDatabase/MDDConfiguration.h>
#import <MDObjectDatabase/MDDCompat.h>
#import <MDObjectDatabase/MDDErrorCode.h>
#import <MDObjectDatabase/MDDReferenceDatabase.h>


