//
//  XspfMRuleEditorRow.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

@interface XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren;
- (void)addChild:(XspfMRule *)child;
- (void)setPredicateParts:(NSDictionary *)parts;
- (void)setExpression:(id)expression forKey:(id)key;
- (void)setValue:(NSString *)newValue;
@end

@interface XspfMRule (XspfMExpressionBuilder)
@end

@implementation XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren
{
	if(!newChildren) newChildren = [NSArray array];
	
	[children autorelease];
	children = [newChildren mutableCopy];
}
- (void)addChild:(XspfMRule *)child
{
	[children addObject:child];
}
- (void)setPredicateParts:(NSDictionary *)parts
{
	[predicateHints autorelease];
	predicateHints = [parts mutableCopy];
}
- (void)setExpression:(id)expression forKey:(id)key
{
	[predicateHints setObject:expression forKey:key];
}
- (void)setValue:(NSString *)newValue
{
	if([value isEqualToString:newValue]) return;
	
	[value autorelease];
	value = [newValue copy];
}
- (NSString *)value { return value; }
@end

@implementation XspfMRule
@dynamic value;

- (NSInteger)numberOfChildren
{
	return [children count];
}
- (id)childAtIndex:(NSInteger)index
{
	return [children objectAtIndex:index];
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return value;
}
#if 1
- (NSDictionary *)predicatePartsWithDisplayValue:(id)displayValue forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	id result = [NSMutableDictionary dictionary];
	
	NSRuleEditorRowType rowType = [ruleEditor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		return predicateHints;
	}
	
	if([predicateHints valueForKey:@"XspfMIgnoreExpression"])  return nil;	
	
	id operatorType = [predicateHints valueForKey:@"NSRuleEditorPredicateOperatorType"];
	id option = [predicateHints valueForKey:@"NSRuleEditorPredicateOptions"];
	id leftExp = [predicateHints valueForKey:@"NSRuleEditorPredicateLeftExpression"];
	id rightExp = [predicateHints valueForKey:@"NSRuleEditorPredicateRightExpression"];
	id customRightExp = [predicateHints valueForKey:@"XspfMPredicateRightExpression"];
	
	if(operatorType) {
		[result setValue:operatorType forKey:@"NSRuleEditorPredicateOperatorType"];
	}
	if(option) {
		[result setValue:option forKey:@"NSRuleEditorPredicateOptions"];
	}
	if(leftExp) {
		id exp = nil;
		if([leftExp isEqual:@"value"]) {
			exp = [NSExpression expressionForKeyPath:displayValue];
		} else {
			exp = [NSExpression expressionForKeyPath:leftExp];
		}
		if(exp) {
			[result setValue:exp forKey:@"NSRuleEditorPredicateLeftExpression"];
		}
	}
	if(rightExp) {
		SEL selector = NSSelectorFromString(rightExp);
		id exp = nil;
		if(selector) {
			exp = [NSExpression expressionForConstantValue:[displayValue performSelector:selector]];
		} else {
			exp = [NSExpression expressionForConstantValue:rightExp];
		}
		if(exp) {
			[result setValue:exp forKey:@"NSRuleEditorPredicateRightExpression"];
		}
	}
	if(customRightExp) {
		SEL selector = NSSelectorFromString(customRightExp);
		id arg01 = [predicateHints valueForKey:@"XspfMRightExpressionArg01"];
		id arg02 = [predicateHints valueForKey:@"XspfMRightExpressionArg02"];
		
		
		if(arg02 && arg01) {
			if([arg01 isEqual:@"displayValues"]) {
				arg01 = [ruleEditor displayValuesForRow:row];
			}
			if([arg02 isEqual:@"displayValues"]) {
				arg02 = [ruleEditor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01 withObject:arg02];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		} else if(arg01) {
			if([arg01 isEqual:@"displayValues"]) {
				arg01 = [ruleEditor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		} else {
			id r = [self performSelector:selector];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		}
	}
	
	//	NSLog(@"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", predicateHints, displayValue, row, result);
	
	return result;
}

#else
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
#warning MUST IMPLEMENT
	return predicateHints;
}
#endif
- (id)displayValue { return value; }

- (id)copyWithZone:(NSZone *)zone
{
	XspfMRule *result = [[[self class] allocWithZone:zone] init];
	result->children = [children copy];
	result->predicateHints = [predicateHints copy];
	result->value = [value copy];
	
	return result;
}

- (BOOL)isEqual:(id)other
{
	if([super isEqual:other]) return YES;
	if(![other isKindOfClass:[XspfMRule class]]) return NO;
	
	XspfMRule *o = other;
	if(![value isEqualToString:o->value]) return NO;
//	if(![children isEqual:o->children]) return NO;
//	if(![predicateHints isEqual:o->predicateHints]) return NO;
	
	return YES;
}
- (NSUInteger)hash
{
	return value ? [value hash] : [super hash];
}

- (id)description
{
	return [NSString stringWithFormat:@"%@ {\n\t%@ = %@;\n\t%@ = %@;\n\t%@ = %@;}",
			NSStringFromClass([self class]),
			@"value", value,
			@"hints", predicateHints,
			@"children", children,
			nil];
}
@end

@implementation XspfMRule (XspfMCreation)

- (id)init
{
	[super init];
	
	children = [[NSMutableArray array] retain];
	predicateHints = [[NSMutableDictionary dictionary] retain];
	
	return self;
}

- (id)initWithValue:(NSString *)newValue children:(NSArray *)newChildren predicateHints:(NSDictionary *)parts
{
	[self init];
	
	if([newValue isEqualToString:@"separator"]) {
		[self release];
		return [[XspfMSeparatorRule alloc] initSparetorRule];
	}
	
	NSInteger tag = XspfMDefaultTag;
	XspfMFieldType type = XspfMUnknownType;
	if([newValue hasPrefix:@"textField"]) {
		type = XspfMTextFieldType;
	} else if([newValue hasPrefix:@"dateField"]) {
		type = XspfMDateFieldType;
		if([newValue isEqualToString:@"dateField"]) {
			tag = XspfMPrimaryDateFieldTag;
		} else {
			tag = XspfMSeconraryDateFieldTag;
		}
	} else if([newValue hasPrefix:@"rateField"]) {
		type = XspfMRateFieldType;
	} else if([newValue hasPrefix:@"numberField"]) {
		type = XspfMNumberFieldType;
		if([newValue isEqualToString:@"numberField"]) {
			tag = XspfMPrimaryNumberFieldTag;
		} else {
			tag = XspfMSecondaryNumberFieldTag;
		}
	}
	if(type != XspfMUnknownType) {
		[self release];
		self = [[XspfMFieldRule alloc] initWithFieldType:type tag:tag];
	}
	
	[self setValue:newValue];
	[self setChildren:newChildren];
	[self setPredicateParts:parts];
	
	return self;
}
+ (id)ruleWithValue:(NSString *)newValue children:(NSArray *)newChildren predicateHints:(NSDictionary *)parts
{
	return [[[self alloc] initWithValue:newValue children:newChildren predicateHints:parts] autorelease];
}

+ (NSArray *)compoundRule
{
	id comp = [self ruleWithValue:@"of the following are true" children:nil predicateHints:[NSDictionary dictionary]];
	
	id allExp = [NSNumber numberWithUnsignedInt:NSAndPredicateType];
	id all = [self ruleWithValue:@"All"
						children:[NSArray arrayWithObject:comp]
				  predicateHints:[NSDictionary dictionaryWithObject:allExp forKey:NSRuleEditorPredicateCompoundType]];
	
	id anyExp = [NSNumber numberWithUnsignedInt:NSOrPredicateType];
	id any = [self ruleWithValue:@"Any"
						children:[NSArray arrayWithObject:comp]
				  predicateHints:[NSDictionary dictionaryWithObject:anyExp forKey:NSRuleEditorPredicateCompoundType]];
	
	return [NSArray arrayWithObjects:all, any, nil];
}

- (NSDictionary *)predicateHintsWithPlist:(NSDictionary *)plist
{
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:plist];
	[result removeObjectForKey:@"criteria"];
	[result removeObjectForKey:@"value"];
	
	return result;
}

+ (id)ruleWithPlist:(id)plist
{
	return [[[self alloc] initWithPlist:plist] autorelease];
}
- (id)initWithPlist:(id)plist
{
	if(![plist isKindOfClass:[NSDictionary class]]) {
		[self init];
		[self release];
		return nil;
	}
	
	id pValue = [plist valueForKey:@"value"];
	id criteria = [plist valueForKey:@"criteria"];
	id pChildren = [NSMutableArray array];
	for(id criterion in criteria) {
		id c = [[self class] ruleWithPlist:criterion];
		if(c) [pChildren addObject:c];
	}
	id hints = [self predicateHintsWithPlist:plist];
	
	return [self initWithValue:pValue children:pChildren predicateHints:hints];
}

- (void)dealloc
{
	[children release];
	[predicateHints release];
	[value release];
	
	[super dealloc];
}

@end


@implementation XspfMSeparatorRule
+ (id)separatorRule
{
	return [[[self alloc] initSparetorRule] autorelease];
}
- (id)initSparetorRule
{
	[super init];
	
	return self;
}
- (id)displayValue
{
	return [NSMenuItem separatorItem];
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return [NSMenuItem separatorItem];
}
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return nil;
}
@end

@implementation XspfMFieldRule
+ (id)ruleWithFieldType:(XspfMFieldType)aType
{
	return [[[self alloc] initWithFieldType:aType tag:XspfMDefaultTag] autorelease];
}
- (id)initWithFieldType:(XspfMFieldType)aType
{
	return [self initWithFieldType:aType tag:XspfMDefaultTag];
}
+ (id)ruleWithFieldType:(XspfMFieldType)aType tag:(NSInteger)aTag
{
	return [[[self alloc] initWithFieldType:aType tag:aTag] autorelease];
}
- (id)initWithFieldType:(XspfMFieldType)aType tag:(NSInteger)aTag
{
	[super init];
	
	type = aType;
	tag = aTag;
	
	return self;
}
- (id)copyWithZone:(NSZone *)zone
{
	XspfMFieldRule *result = [super copyWithZone:zone];
	result->type = type;
	result->tag = tag;
	
	return result;
}
- (void)dealloc
{
	[field release];
	[super dealloc];
}
- (BOOL)isEqual:(id)other
{
	if(![super isEqual:other]) return NO;
	
	XspfMFieldRule *o = other;
	if(tag != o->tag) return NO;
	if(type != o->type) return NO;
	
	return YES;
}

- (NSView *)textField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"1234567890"];
	[text sizeToFit];
	[text setStringValue:@""];
	[text setDelegate:self];
	
	return text;
}
- (NSView *)datePicker
{
	id date = [[[NSDatePicker alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[date cell] setControlSize:NSSmallControlSize];
	[date setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[date setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
	[date setDrawsBackground:YES];
	[date setDateValue:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	[date sizeToFit];
	[date setDelegate:self];
	
	return date;
}
- (NSView *)ratingIndicator
{
	id rate = [[[NSLevelIndicator alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	id cell = [rate cell];
	[cell setControlSize:NSSmallControlSize];
	[rate setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[rate setMinValue:0];
	[rate setMaxValue:5];
	[cell setLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	[cell setEditable:YES];
	[rate sizeToFit];
	
	return rate;
}
- (NSView *)numberField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"123"];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimum:[NSNumber numberWithInt:0]];
	[text setFormatter:formatter];
	[text sizeToFit];
	[text setStringValue:@"1"];
	[text setDelegate:self];
	
	return text;
}

- (Class)fieldClass
{
	Class result = Nil;
	switch(type) {
		case XspfMTextFieldType:
		case XspfMNumberFieldType:
			result = [NSTextField class];
			break;
		case XspfMDateFieldType:
			result = [NSDatePicker class];
			break;
		case XspfMRateFieldType:
			result = [NSLevelIndicator class];
			break;
	}
	return result;
}
- (SEL)fieldCreateSelector
{
	SEL result = Nil;
	switch(type) {
		case XspfMTextFieldType:
			result = @selector(textField);
			break;
		case XspfMNumberFieldType:
			result = @selector(numberField);
			break;
		case XspfMDateFieldType:
			result = @selector(datePicker);
			break;
		case XspfMRateFieldType:
			result = @selector(ratingIndicator);
			break;
	}
	return result;
}
- (id)displayValue
{
	if(field) return field;
	
	id res = [self performSelector:[self fieldCreateSelector]];
	[res setTag:tag];
	
	return res;
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	if(field) return field;
	
	id displayValues = [ruleEditor displayValuesForRow:row];
	Class fieldCalss = [self fieldClass];
	for(id v in displayValues) {
		if([v isKindOfClass:fieldCalss] && [v tag] == tag) {
			field = [v retain];
			break;
		}
	}
	if(!field) field = [[self displayValue] retain];
	
	return field;
}
//- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
//{
//#warning MUST IMPLEMENT
//	return nil;
//}
@end

@implementation XspfMRule (XspfMExpressionBuilder)
- (NSExpression *)rangeUnitFromDisplayValues:(NSArray *)displayValues option:(NSNumber *)optionValue
{
	NSInteger option = [optionValue integerValue];
	
	NSString *variable = nil;
	id value02 = [displayValues objectAtIndex:2];
	id value03 = [displayValues objectAtIndex:3];
	id value04 = nil, value05 = nil;
	switch(option) {
		case 0:
			variable = [NSString stringWithFormat:@"%d-%@-ago", [value02 intValue], value03];
			break;
		case 1:
			variable = [NSString stringWithFormat:@"%d-%@", [value02 intValue], value03];
			break;
		case 2:
			variable = [NSString stringWithFormat:@"not-%d-%@", [value02 intValue], value03];
			break;
		case 3:
			value04 = [displayValues objectAtIndex:4];
			value05 = [displayValues objectAtIndex:5];
			variable = [NSString stringWithFormat:@"%d-%@-%d-%@", [value02 intValue], value03, [value04 intValue], value05];
			break;
	}
	
	return [NSExpression expressionForVariable:variable];
}
- (NSExpression *)rangeDateFromDisplayValues:(NSArray *)displayValues
{
	id field01 = nil;
	id field02 = nil;
	
	Class datepickerclass = [NSDatePicker class];
	for(id v in displayValues) {
		if([v isKindOfClass:datepickerclass]) {
			if([v tag] == XspfMPrimaryDateFieldTag) {
				field01 = v;
			} else {
				field02 = v;
			}
		}
	}
	
	if(!field01 || !field02) return nil;
	
	id value01, value02;
	value01 = [field01 dateValue]; value02 = [field02 dateValue];
	if([value01 compare:value02] == NSOrderedDescending) {
		id t = value02;
		value02 = value01;
		value01 = t;
	}
	
	id expression01, expression02;
	expression01 = [NSExpression expressionForConstantValue:value01];
	expression02 = [NSExpression expressionForConstantValue:value02];
	
	return [NSExpression expressionForAggregate:[NSArray arrayWithObjects:expression01, expression02, nil]];
}
- (NSExpression *)relatedDate:(NSNumber *)typeValue
{
	NSString *variable = nil;
	NSInteger expType = [typeValue integerValue];
	switch(expType) {
		case 0:
			variable = @"TODAY";
			break;
		case 1:
			variable = @"YESTERDAY";
			break;
		case 2:
			variable = @"THISWEEK";
			break;
		case 3:
			variable = @"LASTWEEK";
			break;
	}
	
	return [NSExpression expressionForVariable:variable];
}
@end

