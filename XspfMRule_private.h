//
//  XspfMRule_private.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/17.
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

@interface XspfMRule (XspfMPrivate)
- (NSView *)textField;
- (NSView *)datePicker;
- (NSView *)ratingIndicator;
- (NSView *)numberField;
@end

@interface XspfMFieldRule (XspfMPrivate)
+ (id)fieldRuleWithValue:(NSString *)value;
- (id)initWithValue:(NSString *)value;
@end
