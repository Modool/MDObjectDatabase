//
//  MDDDescriptor.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import <objc/message.h>
#import <ctype.h>
#import <pthread.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#import "MDPropertyAttributes.h"

@interface MDPropertyAttributes ()

/**
 * The name of attribute.
 */
@property (nonatomic, copy) NSString *name;

/**
 * Whether this property was declared with the \c readonly attribute.
 */
@property (nonatomic, assign) BOOL readonly;

/**
 * Whether this property was declared with the \c nonatomic attribute.
 */
@property (nonatomic, assign) BOOL nonatomic;

/**
 * Whether the property is a weak reference.
 */
@property (nonatomic, assign) BOOL weak;

/**
 * Whether the property is eligible for garbage collection.
 */
@property (nonatomic, assign) BOOL canBeCollected;

/**
 * Whether this property is defined with \c \@dynamic.
 */
@property (nonatomic, assign) BOOL dynamic;

/**
 * The memory management policy for this property. This will always be
 * #MDPropertyMemoryManagementPolicyAssign if #readonly is \c YES.
 */
@property (nonatomic, assign) MDPropertyMemoryManagementPolicy memoryManagementPolicy;

/**
 * The selector for the getter of this property. This will reflect any
 * custom \c getter= attribute provided in the property declaration, or the
 * inferred getter name otherwise.
 */
@property (nonatomic, assign) SEL getter;

/**
 * The selector for the setter of this property. This will reflect any
 * custom \c setter= attribute provided in the property declaration, or the
 * inferred setter name otherwise.
 *
 * @note If #readonly is \c YES, this value will represent what the setter
 * \e would be, if the property were writable.
 */
@property (nonatomic, assign) SEL setter;

/**
 * The backing instance variable for this property, or \c NULL if \c
 * \c @synthesize was not used, and therefore no instance variable exists. This
 * would also be the case if the property is implemented dynamically.
 */
@property (nonatomic, assign) const char *ivar;

/**
 * If this property is defined as being an instance of a specific class,
 * this will be the class object representing it.
 *
 * This will be \c nil if the property was defined as type \c id, if the
 * property is not of an object type, or if the class could not be found at
 * runtime.
 */
@property (nonatomic, strong) Class objectClass;

/**
 * The type encoding for the value of this property. This is the type as it
 * would be returned by the \c \@encode() directive.
 */
@property (nonatomic, copy) NSString *typeString;

/**
 * The type encoding for the value of this property. This is the type as it
 * would be returned by the \c \@encode() directive.
 */
@property (nonatomic, copy) NSString *type;

@end

@implementation MDPropertyAttributes

@end

MDPropertyAttributes *MDCopyPropertyAttributes (objc_property_t property) {
    const char * const attrString = property_getAttributes(property);
    if (!attrString) {
        fprintf(stderr, "ERROR: Could not get attribute string from property %s\n", property_getName(property));
        return nil;
    }

    if (attrString[0] != 'T') {
        fprintf(stderr, "ERROR: Expected attribute string \"%s\" for property %s to start with 'T'\n", attrString, property_getName(property));
        return nil;
    }

    const char *typeString = attrString + 1;
    const char *next = NSGetSizeAndAlignment(typeString, nil, nil);
    if (!next) {
        fprintf(stderr, "ERROR: Could not read past type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return nil;
    }

    size_t typeLength = (size_t)(next - typeString);
    if (!typeLength) {
        fprintf(stderr, "ERROR: Invalid type in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return nil;
    }

    // allocate enough space for the structure and the type string (plus a NUL)
    MDPropertyAttributes *attributes = [MDPropertyAttributes new];
    if (!attributes) {
        fprintf(stderr, "ERROR: Could not allocate MDPropertyAttributes structure for attribute string \"%s\" for property %s\n", attrString, property_getName(property));
        return nil;
    }

    // copy the type string
    attributes.typeString = [NSString stringWithUTF8String:attrString];

    // if this is an object type, and immediately followed by a quoted string...
    if (typeString[0] == *(@encode(id)) && typeString[1] == '"') {
        // we should be able to extrlt a class name
        const char *className = typeString + 2;
        next = strchr(className, '"');

        if (!next) {
            fprintf(stderr, "ERROR: Could not read class name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
            return nil;
        }

        if (className != next) {
            size_t classNameLength = (size_t)(next - className);
            char trimmedName[classNameLength + 1];

            strncpy(trimmedName, className, classNameLength);
            trimmedName[classNameLength] = '\0';

            // attempt to look up the class in the runtime
            attributes.objectClass = objc_getClass(trimmedName);
        }
    } else {
        // copy the type string
        attributes.type = [[NSString stringWithUTF8String:typeString] substringToIndex:1];
    }

    if (*next != '\0') {
        // skip past any junk before the first flag
        next = strchr(next, ',');
    }

    while (next && *next == ',') {
        char flag = next[1];
        next += 2;

        switch (flag) {
        case '\0':
            break;

        case 'R':
            attributes.readonly = YES;
            break;

        case 'C':
            attributes.memoryManagementPolicy = MDPropertyMemoryManagementPolicyCopy;
            break;

        case '&':
            attributes.memoryManagementPolicy = MDPropertyMemoryManagementPolicyRetain;
            break;

        case 'N':
            attributes.nonatomic = YES;
            break;

        case 'G':
        case 'S':
            {
                const char *nextFlag = strchr(next, ',');
                SEL name = nil;

                if (!nextFlag) {
                    // assume that the rest of the string is the selector
                    const char *selectorString = next;
                    next = "";

                    name = sel_registerName(selectorString);
                } else {
                    size_t selectorLength = (size_t)(nextFlag - next);
                    if (!selectorLength) {
                        fprintf(stderr, "ERROR: Found zero length selector name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
                        return nil;
                    }

                    char selectorString[selectorLength + 1];

                    strncpy(selectorString, next, selectorLength);
                    selectorString[selectorLength] = '\0';

                    name = sel_registerName(selectorString);
                    next = nextFlag;
                }

                if (flag == 'G')
                    attributes.getter = name;
                else
                    attributes.setter = name;
            }

            break;

        case 'D':
            attributes.dynamic = YES;
            attributes.ivar = nil;
            break;

        case 'V':
            // assume that the rest of the string (if present) is the ivar name
            if (*next == '\0') {
                // if there's nothing there, let's assume this is dynamic
                attributes.ivar = nil;
            } else {
                attributes.ivar = next;
                next = "";
            }

            break;

        case 'W':
            attributes.weak = YES;
            break;

        case 'P':
            attributes.canBeCollected = YES;
            break;

        case 't':
            fprintf(stderr, "ERROR: Old-style type encoding is unsupported in attribute string \"%s\" for property %s\n", attrString, property_getName(property));

            // skip over this type encoding
            while (*next != ',' && *next != '\0')
                ++next;

            break;

        default:
            fprintf(stderr, "ERROR: Unrecognized attribute string flag '%c' in attribute string \"%s\" for property %s\n", flag, attrString, property_getName(property));
        }
    }

    if (next && *next != '\0') {
        fprintf(stderr, "Warning: Unparsed data \"%s\" in attribute string \"%s\" for property %s\n", next, attrString, property_getName(property));
    }

    if (!attributes.getter) {
        // use the property name as the getter by default
        attributes.getter = sel_registerName(property_getName(property));
    }

    if (!attributes.setter) {
        const char *propertyName = property_getName(property);
        size_t propertyNameLength = strlen(propertyName);

        // we want to transform the name to setProperty: style
        size_t setterLength = propertyNameLength + 4;

        char setterName[setterLength + 1];
        strncpy(setterName, "set", 3);
        strncpy(setterName + 3, propertyName, propertyNameLength);

        // capitalize property name for the setter
        setterName[3] = (char)toupper(setterName[3]);

        setterName[setterLength - 1] = ':';
        setterName[setterLength] = '\0';

        attributes.setter = sel_registerName(setterName);
    }
    
    attributes.name = [NSString stringWithUTF8String:property_getName(property)];

    return attributes;
}

Method MDImmediateInstanceMethod(Class aClass, SEL aSelector) {
    unsigned methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    Method foundMethod = nil;

    for (unsigned methodIndex = 0;methodIndex < methodCount;++methodIndex) {
        if (method_getName(methods[methodIndex]) != aSelector) continue;
        
        foundMethod = methods[methodIndex];
    }

    free(methods);
    return foundMethod;
}

NSArray<MDPropertyAttributes *> *MDPropertyAttributesForCurrentClass(Class<NSObject> class){
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    
    NSMutableArray<MDPropertyAttributes *> *resultProperties = [NSMutableArray<MDPropertyAttributes *> new];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        MDPropertyAttributes *resultProperty = MDCopyPropertyAttributes(property);
        
        if (!resultProperty) continue;
        
        [resultProperties addObject:resultProperty];
    }
    free(properties);
    
    return [resultProperties copy];
}

NSArray<MDPropertyAttributes *> *MDPropertyAttributesForClass(Class<NSObject> class, BOOL containedSuperClass){
    if (!containedSuperClass) return MDPropertyAttributesForCurrentClass(class);
    
    NSMutableArray<MDPropertyAttributes *> *resultProperties = [NSMutableArray<MDPropertyAttributes *> new];
    Class currentClass = class;
    do {
        NSArray<MDPropertyAttributes *> *properties = MDPropertyAttributesForCurrentClass(currentClass);
        if (!properties) continue;
        
        [resultProperties addObjectsFromArray:properties];
    } while ((currentClass = [currentClass superclass]) && currentClass != [NSObject class]);
    
    return [resultProperties copy];
}
