//
//  MDDMacros.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#if !defined(MDD_EXTERN)

#if defined(__cplusplus)
#define MDD_EXTERN extern "C"
#else
#define MDD_EXTERN extern
#endif
#endif

#if !defined(MDD_STATIC_INLINE)
#define MDD_STATIC_INLINE static __inline__
#endif

#if !defined(MDD_EXTERN_INLINE)
#define MDD_EXTERN_INLINE extern __inline__
#endif

#if !defined(MDD_STATIC_CONST)
#define MDD_STATIC_CONST static const
#endif

#if !defined(MDDKeyPath)
#define MDDKeyPath(CLASS, PATH) (((void)(NO && ((void)CLASS.new.PATH, NO)), # PATH))
#endif

#if !defined(NSSetObject)
#define NSSetObject(OBJECT)  [NSSet setWithObject:OBJECT]
#endif

#if !defined(NSSetObjects)
#define NSSetObjects(OBJECT, ...)  [NSSet setWithObjects:OBJECT, ##__VA_ARGS__, nil]
#endif

#if !defined(NSSetArray)
#define NSSetArray(...)  [NSSet setWithArray:##__VA_ARGS__]
#endif

#if !defined(NSSetObject)
#define NSSetObject(OBJECT)  [NSSet setWithObject:OBJECT]
#endif
