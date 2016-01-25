//
//  MSPTouchableLabel.m
//  MSPTouchableLabel
//
//  Created by Michael Pace on 4/12/15.
//  Copyright (c) 2015 Michael Pace. All rights reserved.
//

#import "MSPTouchableLabel.h"

#define kMSPTouchableLabelKeySubstringRange     @"substringRange"
#define kMSPTouchableLabelKeyTextSectionIndex   @"textSectionIndex"

@interface MSPTouchableLabel()

@property (nonatomic, strong) NSMutableDictionary* textPieceIndexToAreaMap;
@property (nonatomic, strong) NSNumber* lastIndexTouched;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSArray* overrideAttributes;

@end

@implementation MSPTouchableLabel

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configureSelf];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self configureSelf];
    }
    
    return self;
}

- (void)configureSelf {
    self.multiLineRenderingOptimizationsEnabled = YES;
    self.userInteractionEnabled = YES;
}

#pragma mark - Getters and setters

- (void)setText:(NSString*)text {
    // don't do anything. we set the text of this label differently.
    NSException* exception = [NSException
                              exceptionWithName:@"SetTextException"
                              reason:@"Do not set the text property of an instance of MSPTouchableLabel. Instead, use MSPTouchableLabelDataSource to set text."
                              userInfo:nil];
    @throw exception;
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize {
    return self.contentSize;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    NSNumber* indexForTapCoordinates = [self indexForTouchEvent:event];
    
    if (indexForTapCoordinates == nil) {
        return;
    }
    self.lastIndexTouched = indexForTapCoordinates;
    
    if ([(NSObject*)self.dataSource respondsToSelector:@selector(touchableLabel:touchesDidBeginAtIndex:)]) {
        [self.delegate touchableLabel:self touchesDidBeginAtIndex:indexForTapCoordinates.integerValue];
    }
    
    // setNeedsDisplay in case delegate updated our data source
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    NSNumber* indexForTapCoordinates = [self indexForTouchEvent:event];
    
    if (self.lastIndexTouched == nil || [indexForTapCoordinates isEqualToNumber:self.lastIndexTouched]) {
        // only tell the delegate if a new index was touched, and only if the touch began on a label.
        return;
    }
    self.lastIndexTouched = indexForTapCoordinates;
    
    if (indexForTapCoordinates == nil) {
        if ([(NSObject*)self.dataSource respondsToSelector:@selector(touchesDidMoveFromLabel:)]) {
            [self.delegate touchesDidMoveFromLabel:self];
        }
    } else {
        if ([(NSObject*)self.dataSource respondsToSelector:@selector(touchableLabel:touchesDidMoveToIndex:)]) {
            [self.delegate touchableLabel:self touchesDidMoveToIndex:indexForTapCoordinates.integerValue];
        }
    }
    
    // setNeedsDisplay in case delegate updated our data source
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    NSNumber* indexForTapCoordinates = [self indexForTouchEvent:event];
    
    if (indexForTapCoordinates == nil) {
        return;
    }
    self.lastIndexTouched = nil;
    
    if ([(NSObject*)self.dataSource respondsToSelector:@selector(touchableLabel:touchesDidEndAtIndex:)]) {
        [self.delegate touchableLabel:self touchesDidEndAtIndex:indexForTapCoordinates.integerValue];
    }
    
    // setNeedsDisplay in case delegate updated our data source
    [self setNeedsDisplay];
}

#pragma mark - UILabel

- (void)drawTextInRect:(CGRect)rect {
    NSArray* textSections = [self.dataSource textForTouchableLabel:self];
    
    [self drawTextSections:textSections inRect:rect];
}

#pragma mark - ()

- (void)drawTextSections:(NSArray*)textSections inRect:(CGRect)rect {
    // which characters should be grouped when drawing? e.g., if user passed in @[@"he", @"llo w", @"orld"], we'd want
    // the characters in "hello" to be drawn together even though they were passed in as different textSections, and same
    // with "world".
    NSArray* drawablePieces = [self drawablePiecesWithinString:[textSections componentsJoinedByString:@""]];

    // which textSections apply to which drawablePieces? this can affect how the drawablePieces are drawn (e.g., drawablePiece "hello"
    // being made up of 32-point "h" and 20-point "ello").
    NSArray* drawablePieceToTextSectionMaps = [self mapTextSections:textSections toDrawablePieces:drawablePieces];

    CGFloat touchableLabelWidth = rect.size.width;
    CGPoint lookaheadDrawHead = CGPointMake(0.0f, 0.0f);
    NSCharacterSet* whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    // as a side effect in this method, we want to populate self.indexToAreaMap so we can tell our delegate which index a user has interacted
    // with later on.
    self.textPieceIndexToAreaMap = self.textPieceIndexToAreaMap ?: [[NSMutableDictionary alloc] init];
    [self.textPieceIndexToAreaMap removeAllObjects];

    NSString* bufferedString = @"";
    NSDictionary* attributes = nil;
    CGPoint actualDrawHead = CGPointMake(0.0f, 0.0f);
    NSDictionary* previousAttributes = nil;

    // as a side effect in this method, we want to note the size of the content we draw for later use in intrinsicContentSize and elsewhere.
    CGSize contentSize = CGSizeZero;

    // loop through our drawablePieces and draw them.
    for (int i = 0; i < drawablePieces.count; i++) {
        NSString* drawablePiece = drawablePieces[i];
        NSArray* textSectionChunks = drawablePieceToTextSectionMaps[i];
        CGSize drawablePieceSize = [self sizeForDrawablePiece:drawablePiece withTextSectionChunks:textSectionChunks];

        // can we fit the drawablePiece on this line or should we move it to the next line?
        if (lookaheadDrawHead.x + drawablePieceSize.width > touchableLabelWidth) {
            lookaheadDrawHead.x = 0;
            lookaheadDrawHead.y += drawablePieceSize.height;

            if (self.multiLineRenderingOptimizationsEnabled && actualDrawHead.x == 0.0f) {
                // if our draw head is at x == 0, instead of drawing, just add a newline so we can batch drawAtPoint calls.
                bufferedString = [bufferedString stringByAppendingString:@"\n"];
            } else {
                [bufferedString drawAtPoint:CGPointMake(actualDrawHead.x, actualDrawHead.y) withAttributes:previousAttributes];
                actualDrawHead = CGPointMake(lookaheadDrawHead.x, lookaheadDrawHead.y);
                bufferedString = @"";
            }

            if ([drawablePiece stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet].length == 0) {
                // don't start a new line with whitespace. might want to change this behavior in the future.
                continue;
            }
        }

        for (NSDictionary* chunk in textSectionChunks) {
            NSInteger textSectionIndex = [[chunk objectForKey:kMSPTouchableLabelKeyTextSectionIndex] integerValue];
            attributes = [self attributesForIndex:textSectionIndex];
            NSRange range = [[chunk objectForKey:kMSPTouchableLabelKeySubstringRange] rangeValue];
            NSString* drawablePieceSubstring = [drawablePiece substringWithRange:range];

            // set previousAttributes to attributes the first time through the loop.
            previousAttributes = previousAttributes ?: attributes;
            if ([attributes isEqualToDictionary:previousAttributes]) {
                bufferedString = [bufferedString stringByAppendingString:drawablePieceSubstring];
            } else {
                // draw previous chunk!
                [bufferedString drawAtPoint:CGPointMake(actualDrawHead.x, actualDrawHead.y) withAttributes:previousAttributes];
                actualDrawHead = CGPointMake(lookaheadDrawHead.x, lookaheadDrawHead.y);
                bufferedString = drawablePieceSubstring;
            }

            // record where we place this chunk!
            CGSize drawablePieceSubstringSize = [drawablePieceSubstring sizeWithAttributes:attributes];
            NSMutableArray* areasForCurrentWord = [self.textPieceIndexToAreaMap objectForKey:@(textSectionIndex)] ?: [[NSMutableArray alloc] init];
            CGRect wordArea = CGRectMake(lookaheadDrawHead.x, lookaheadDrawHead.y, drawablePieceSubstringSize.width, drawablePieceSubstringSize.height);
            // can't add primitive CGRect to a collection. wrap it into an NSValue and unwrap later.
            [areasForCurrentWord addObject:[NSValue valueWithCGRect:wordArea]];
            [self.textPieceIndexToAreaMap setObject:areasForCurrentWord forKey:@(textSectionIndex)];

            contentSize.width = MAX(contentSize.width, wordArea.origin.x + wordArea.size.width);
            contentSize.height = MAX(contentSize.height, wordArea.origin.y + wordArea.size.height);

            lookaheadDrawHead.x += drawablePieceSubstringSize.width;
            previousAttributes = attributes;
        }
    }

    // this is the last chunk and we didn't draw it yet. draw it here.
    [bufferedString drawAtPoint:CGPointMake(actualDrawHead.x, actualDrawHead.y) withAttributes:attributes];
    self.contentSize = contentSize;
}

- (MSPTouchEventLocation)touchEventLocationAtPoint:(CGPoint)point {
    MSPTouchEventLocation touchEventLocation = {};
    
    for (NSNumber* index in self.textPieceIndexToAreaMap) {
        NSArray* areas = self.textPieceIndexToAreaMap[index];
        CGSize textPieceSize = CGSizeZero;
        for (NSInteger i = 0; i < areas.count; i++) {
            NSValue* areaWrapper = areas[i];
            CGRect area = [areaWrapper CGRectValue];
            
            if (CGRectContainsPoint(area, point)) {
                CGPoint adjustedPoint = CGPointMake(point.x - area.origin.x, point.y - area.origin.y);
                adjustedPoint.x += textPieceSize.width;
                
                for (; i < areas.count; i++) {
                    textPieceSize.width += area.size.width;
                    textPieceSize.height = MAX(textPieceSize.height, area.size.height);
                }
                
                touchEventLocation.point = point;
                touchEventLocation.index = index.integerValue;
                touchEventLocation.textPieceSize = textPieceSize;
                touchEventLocation.adjustedPoint = adjustedPoint;
                
                
                return touchEventLocation;
            }
            
            textPieceSize.width += area.size.width;
            textPieceSize.height = MAX(textPieceSize.height, area.size.height);
        }
    }
    
    touchEventLocation.point = CGPointZero;
    touchEventLocation.index = -1;
    touchEventLocation.textPieceSize = CGSizeZero;
    touchEventLocation.adjustedPoint = CGPointZero;
    
    return touchEventLocation;
}

- (NSNumber*)indexForTouchEvent:(UIEvent*)event {
    CGPoint tapCoordinates = [event.allTouches.anyObject locationInView:self];
    MSPTouchEventLocation touchEventLocation = [self touchEventLocationAtPoint:tapCoordinates];
    return @(touchEventLocation.index);
}

- (NSDictionary*)attributesForIndex:(NSInteger)index {
    NSDictionary* attributes = [self defaultAttributes];

    if (self.overrideAttributes) {
        if (self.overrideAttributes.count > index) {
            attributes = self.overrideAttributes[index];
        }
    } else if ([(NSObject*)self.dataSource respondsToSelector:@selector(attributesForTouchableLabel:atIndex:)]) {
        NSMutableDictionary* newAttributes = [attributes mutableCopy];
        NSDictionary* specialAttributes = [self.dataSource attributesForTouchableLabel:self atIndex:index];
        if (specialAttributes) {
            [newAttributes addEntriesFromDictionary:specialAttributes];
        }
        attributes = newAttributes;
    }
    
    return attributes;
}

- (NSArray*)drawablePiecesWithinString:(NSString*)string {
    NSCharacterSet* whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet* nonWhitespaceAndNewlineCharacterSet = [whitespaceAndNewlineCharacterSet invertedSet];
    NSPredicate* hasLengthPredicate = [NSPredicate predicateWithFormat:@"length > 0"];
    
    NSArray* nonWhitespaceSections = [[string componentsSeparatedByCharactersInSet:whitespaceAndNewlineCharacterSet] filteredArrayUsingPredicate:hasLengthPredicate];
    NSArray* whitespaceSections = [[string componentsSeparatedByCharactersInSet:nonWhitespaceAndNewlineCharacterSet] filteredArrayUsingPredicate:hasLengthPredicate];
    NSMutableArray* drawablePieces = [[NSMutableArray alloc] initWithCapacity:nonWhitespaceSections.count + whitespaceSections.count];
    
    BOOL startWithWhitespaceSections = string.length && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[string characterAtIndex:0]];
    for (int i = 0; i < nonWhitespaceSections.count + whitespaceSections.count; i++) {
        BOOL currentSectionIsWhitespace = (startWithWhitespaceSections && i % 2 == 0) || (!startWithWhitespaceSections && i % 2 != 0);
        NSString* currentSection = currentSectionIsWhitespace ? [whitespaceSections objectAtIndex:i/2] : [nonWhitespaceSections objectAtIndex:i/2];
        [drawablePieces addObject:currentSection];
    }
    
    return drawablePieces;
}

- (NSArray*)mapTextSections:(NSArray*)textSections toDrawablePieces:(NSArray*)drawablePieces {
    NSInteger textSectionPointer = 0;
    NSInteger textSectionConsumptionIndex = 0;
    NSInteger drawablePiecePointer = 0;
    NSInteger drawablePieceConsumptionIndex = 0;
    NSMutableArray* drawablePieceToTextSectionMaps = [[NSMutableArray alloc] initWithCapacity:textSections.count];
    
    while (drawablePiecePointer < drawablePieces.count && textSectionPointer < textSections.count) {
        NSInteger remainingDrawablePieceLength = [drawablePieces[drawablePiecePointer] length] - drawablePieceConsumptionIndex;
        NSInteger remainingTextSectionLength = [textSections[textSectionPointer] length] - textSectionConsumptionIndex;
        
        if (remainingDrawablePieceLength == 0) {
            // we've consumed the whole drawablePiece. move on to the next drawablePiece and continue.
            drawablePiecePointer += 1;
            drawablePieceConsumptionIndex = 0;
            continue;
        }
        if (remainingTextSectionLength == 0) {
            // we've consumed the whole textSection. move on to the next textSection and continue.
            textSectionPointer += 1;
            textSectionConsumptionIndex = 0;
            continue;
        }
        
        // there is something left to consume in either the drawablePiece or the textSection. do it!
        NSInteger shorterConsumptionLength = MIN(remainingDrawablePieceLength, remainingTextSectionLength);
        NSDictionary* chunk = @{
                                kMSPTouchableLabelKeySubstringRange: [NSValue valueWithRange:NSMakeRange(drawablePieceConsumptionIndex, shorterConsumptionLength)],
                                kMSPTouchableLabelKeyTextSectionIndex: @(textSectionPointer)
                                };
        drawablePieceConsumptionIndex += shorterConsumptionLength;
        textSectionConsumptionIndex += shorterConsumptionLength;
        
        if (drawablePieceToTextSectionMaps.count <= drawablePiecePointer) {
            [drawablePieceToTextSectionMaps addObject:[[NSMutableArray alloc] init]];
        }
        NSMutableArray* drawablePieceArray = drawablePieceToTextSectionMaps[drawablePiecePointer];
        [drawablePieceArray addObject:chunk];
    }
    
    return drawablePieceToTextSectionMaps;
}

- (CGSize)sizeForDrawablePiece:(NSString*)drawablePiece withTextSectionChunks:(NSArray*)textSectionChunks {
    CGSize drawablePieceSize = CGSizeMake(0.0f, 0.0f);
    
    for (NSDictionary* chunk in textSectionChunks) {
        NSRange range = [[chunk objectForKey:kMSPTouchableLabelKeySubstringRange] rangeValue];
        NSString* drawablePieceSubstring = [drawablePiece substringWithRange:range];
        
        NSInteger textSectionIndex = [[chunk objectForKey:kMSPTouchableLabelKeyTextSectionIndex] integerValue];
        NSDictionary* attributes = [self attributesForIndex:textSectionIndex];
        
        CGSize drawablePieceSubstringSize = [drawablePieceSubstring sizeWithAttributes:attributes];
        drawablePieceSize.width += drawablePieceSubstringSize.width;
        drawablePieceSize.height = MAX(drawablePieceSize.height, drawablePieceSubstringSize.height);
    }
    
    return drawablePieceSize;
}

+ (CGSize)sizeForTouchableLabelGivenText:(NSArray*)textSections withAttributes:(NSArray*)attributes inRect:(CGRect)rect {
    if (!textSections || textSections.count == 0 || rect.size.width == 0 || rect.size.height == 0) {
        return CGSizeZero;
    }

    MSPTouchableLabel* touchableLabel = [[MSPTouchableLabel alloc] init];
    touchableLabel.overrideAttributes = attributes;
    [touchableLabel drawTextSections:textSections inRect:rect];
    return touchableLabel.contentSize;
}

- (NSDictionary*)defaultAttributes {
    return @{
             NSFontAttributeName: self.font,
             NSForegroundColorAttributeName: self.textColor,
             NSBackgroundColorAttributeName: self.backgroundColor
             };
}

@end