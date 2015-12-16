//
//  MSPTouchableLabel.h
//  MSPTouchableLabel
//
//  Created by Michael Pace on 4/12/15.
//  Copyright (c) 2015 Michael Pace. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE

@class MSPTouchableLabel;

@protocol MSPTouchableLabelDelegate

@optional
/**
 @discussion            Called as soon as the user touches the touchableLabel.
 @param touchableLabel  The current MSPTouchableLabel.
 @param index           The index (per MSPTouchableLabelDataSource's textForTouchableLabel:).
 */
- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidBeginAtIndex:(NSInteger)index;

/**
 @discussion            Called when a user's touch moves from one MSPTouchableLabel index to a new index.
 @param touchableLabel  The current MSPTouchableLabel.
 @param index           The index (per MSPTouchableLabelDataSource's textForTouchableLabel:).
 */
- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidMoveToIndex:(NSInteger)index;

/**
 @discussion            Called when the user ends a touch on an MSPTouchableLabel index.
 @param touchableLabel  The current MSPTouchableLabel.
 @param index           The index (per MSPTouchableLabelDataSource's textForTouchableLabel:).
 */
- (void)touchableLabel:(MSPTouchableLabel*)touchableLabel touchesDidEndAtIndex:(NSInteger)index;

@end

@protocol MSPTouchableLabelDataSource

/**
 @discussion            Called to discover the text to render in the MSPTouchableLabel. Use this instead of setting the UILabel's `text` property.
 @param touchableLabel  The current MSPTouchableLabel.
 @return                Return an NSArray* of NSString*s. The order of the strings here is the `index` parameter in MSPTouchableLabelDelegate methods as well as MSPTouchableLabelDataSource's attributesForTouchableLabel:atIndex:
 */
- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel;

@optional
/**
 @discussion            Called to discover formatting per string provided in MSPTouchableLabelDataSource's textForTouchableLabel:.
 @param touchableLabel  The current MSPTouchableLabel.
 @param index           The index of the string provided in MSPTouchableLabelDataSource's textForTouchableLabel:.
 @return                Return an NSDictionary* of key-value pairs (e.g., @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:18.0f] }). Return nil if the index should use the MSPTouchableLabel's defaultAttributes.
 */
- (NSDictionary*)attributesForTouchableLabel:(MSPTouchableLabel*)touchableLabel atIndex:(NSInteger)index;

@end

/**
 @discussion            A label users can interact with. Use it like a UITableView. Set a dataSource to provide text for the label and a delegate to find out how the user interacts with the label. Do not set the `text` property of an MSPTouchableLabel.
 */
@interface MSPTouchableLabel : UILabel

/**
 @brief Default attributes for the label. Can override per index with MSPTouchableLabelDataSource's attributesForTouchableLabel:atIndex.
 */
@property (nonatomic, strong) NSDictionary* defaultAttributes;

@property (nonatomic, strong) id<MSPTouchableLabelDataSource> dataSource;
@property (nonatomic, strong) id<MSPTouchableLabelDelegate> delegate;

@end