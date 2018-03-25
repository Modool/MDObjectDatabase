//
//  MDDDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <objc/runtime.h>
#import "MDDMacros.h"

/**
 * Describes the memory management policy of a property.
 */
typedef NS_ENUM(NSUInteger, MDPropertyMemoryManagementPolicy) {
    /**
     * The value is assigned.
     */
    MDPropertyMemoryManagementPolicyAssign = 0,

    /**
     * The value is retained.
     */
    MDPropertyMemoryManagementPolicyRetain,

    /**
     * The value is copied.
     */
    MDPropertyMemoryManagementPolicyCopy
};

/**
 * Describes the attributes and type information of a property.
 */

@interface MDPropertyAttributes : NSObject

/**
 * The name of attribute.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Whether this property was declared with the \c readonly attribute.
 */
@property (nonatomic, assign, readonly) BOOL readonly;

/**
 * Whether this property was declared with the \c nonatomic attribute.
 */
@property (nonatomic, assign, readonly) BOOL nonatomic;

/**
 * Whether the property is a weak reference.
 */
@property (nonatomic, assign, readonly) BOOL weak;

/**
 * Whether the property is eligible for garbage collection.
 */
@property (nonatomic, assign, readonly) BOOL canBeCollected;

/**
 * Whether this property is defined with \c \@dynamic.
 */
@property (nonatomic, assign, readonly) BOOL dynamic;

/**
 * The memory management policy for this property. This will always be
 * #MDPropertyMemoryManagementPolicyAssign if #readonly is \c YES.
 */
@property (nonatomic, assign, readonly) MDPropertyMemoryManagementPolicy memoryManagementPolicy;

/**
 * The selector for the getter of this property. This will reflect any
 * custom \c getter= attribute provided in the property declaration, or the
 * inferred getter name otherwise.
 */
@property (nonatomic, assign, readonly) SEL getter;

/**
 * The selector for the setter of this property. This will reflect any
 * custom \c setter= attribute provided in the property declaration, or the
 * inferred setter name otherwise.
 *
 * @note If #readonly is \c YES, this value will represent what the setter
 * \e would be, if the property were writable.
 */
@property (nonatomic, assign, readonly) SEL setter;

/**
 * The backing instance variable for this property, or \c NULL if \c
 * \c @synthesize was not used, and therefore no instance variable exists. This
 * would also be the case if the property is implemented dynamically.
 */
@property (nonatomic, assign, readonly) const char *ivar;

/**
 * If this property is defined as being an instance of a specific class,
 * this will be the class object representing it.
 *
 * This will be \c nil if the property was defined as type \c id, if the
 * property is not of an object type, or if the class could not be found at
 * runtime.
 */
@property (nonatomic, strong, readonly) Class objectClass;

/**
 * The type encoding for the value of this property. This is the type as it
 * would be returned by the \c \@encode() directive.
 */
@property (nonatomic, copy, readonly) NSString *type;

@end

/**
 * Finds the instance method named \a aSelector on \a aClass and returns it, or
 * returns \c NULL if no such instance method exists. Unlike \c
 * class_getInstanceMethod(), this does not search superclasses.
 *
 * @note To get class methods in this manner, use a metaclass for \a aClass.
 */
MDD_EXTERN Method MDImmediateInstanceMethod (Class aClass, SEL aSelector);

/**
 * Returns a pointer to a structure containing information about \a property.
 * You must \c free() the returned pointer. Returns \c NULL if there is an error
 * obtaining information from \a property.
 */
MDD_EXTERN MDPropertyAttributes *MDCopyPropertyAttributes (objc_property_t property);

MDD_EXTERN NSArray<MDPropertyAttributes *> *MDPropertyAttributesForCurrentClass(Class<NSObject> class);

MDD_EXTERN NSArray<MDPropertyAttributes *> *MDPropertyAttributesForClass(Class<NSObject> class, BOOL containedSuperClass);


