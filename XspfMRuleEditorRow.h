//
//  XspfMRuleEditorRow.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMCompound : NSObject
- (NSInteger)numberOfChildrenForChild:(id)child;
- (id)childForChild:(id)child atIndex:(NSInteger)index;
- (id)displayValueForChild:(id)child;
- (NSDictionary *)predicateForChild:(id)child withDisplayValue:(id)value;
@end



@interface XspfMRule : NSObject <NSCopying>
{
@private
	NSMutableArray *children;
	NSMutableDictionary *predicateHints;
	NSString *_value;
}

@property (copy) NSString *value;

- (NSInteger)numberOfChildren;
- (id)childAtIndex:(NSInteger)index;
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row;
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row;

- (id)displayValue;
@end


@interface XspfMRule (XspfMCreation)
+ (id)ruleWithPlist:(id)plist;
- (id)initWithPlist:(id)plist;

+ (NSArray *)compoundRule;
@end
@interface XspfMRule (XspfMRuleBuilder)
+ (NSArray *)ruleEditorRowsFromPredicate:(NSPredicate *)predicate withRowTemplate:(id)rowTemplate;
- (NSArray *)ruleEditorRowsFromPredicate:(NSPredicate *)predicate withRowTemplate:(id)rowTemplate;
@end


@interface XspfMSeparatorRule : XspfMRule
+ (id)separatorRule;
- (id)initSparetorRule;
@end

typedef enum {
	XspfMUnknownType = 0,
	XspfMTextFieldType = 1,
	XspfMNumberFieldType,
	XspfMDateFieldType,
	XspfMRateFieldType,
} XspfMFieldType;

enum XspfMFieldTag {
	XspfMDefaultTag = 0,
	
	XspfMPrimaryDateFieldTag = 1000,
	XspfMSeconraryDateFieldTag = 1100,
	
	XspfMPrimaryNumberFieldTag = 2000,
	XspfMSecondaryNumberFieldTag = 2100,
};

enum XspfMUnitType {
	XspfMDaysUnitType,
	XpsfMWeeksUnitType,
	XspfMMonthsUnitType,
	XspfMYearsUnitType,
};

@interface XspfMFieldRule : XspfMRule
{
	XspfMFieldType type;
	NSInteger tag;
}
+ (id)ruleWithFieldType:(XspfMFieldType)type;
- (id)initWithFieldType:(XspfMFieldType)type;
+ (id)ruleWithFieldType:(XspfMFieldType)type tag:(NSInteger)tag;
- (id)initWithFieldType:(XspfMFieldType)type tag:(NSInteger)tag;
@end

