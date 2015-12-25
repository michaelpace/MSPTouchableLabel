//
//  MSPTouchableLabelTests.m
//  MSPTouchableLabelTests
//
//  Created by Michael Pace on 4/12/15.
//  Copyright (c) 2015 Michael Pace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MSPTouchableLabel.h"

@interface MSPTouchableLabel(Testing)

- (NSArray*)drawablePiecesWithinString:(NSString*)string;
- (NSArray*)mapTextSections:(NSArray*)textSections toDrawablePieces:(NSArray*)drawablePieces;
- (CGSize)sizeForDrawablePiece:(NSString*)drawablePiece withTextSectionChunks:(NSArray*)textSectionChunks;
- (void)drawTextInRect:(CGRect)rect;

@end

@interface MSPTouchableLabelTests : XCTestCase<MSPTouchableLabelDataSource, MSPTouchableLabelDelegate>

@property (nonatomic, strong) MSPTouchableLabel* touchableLabel;
@property (nonatomic, strong) NSArray* textForTouchableLabel;
@property (nonatomic, strong) UIView* view;

@end

@implementation MSPTouchableLabelTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
    self.touchableLabel = [[MSPTouchableLabel alloc] initWithFrame:self.view.bounds];
    self.touchableLabel.dataSource = self;
    self.touchableLabel.delegate = self;
    [self.view addSubview:self.touchableLabel];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - drawablePiecesWithinString:

- (void)testDrawablePiecesWithinString_correctCount {
    NSString* string = @"Hello, this is a string!";
    NSArray* drawablePieces = [self.touchableLabel drawablePiecesWithinString:string];
    XCTAssertEqual(drawablePieces.count, 9);
}

- (void)testDrawablePiecesWithinString_startingWithWhitespace {
    NSString* string = @" Hello, this is a string!";
    NSArray* drawablePieces = [self.touchableLabel drawablePiecesWithinString:string];
    XCTAssertEqualObjects(drawablePieces[0], @" ");
}

- (void)testDrawablePiecesWithinString_alternatingWhitespace {
    NSString* string = @"Hello, this is a string\nwow!!";
    NSArray* drawablePieces = [self.touchableLabel drawablePiecesWithinString:string];
    BOOL shouldBeWhitespace = NO;
    NSCharacterSet* whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSString* drawablePiece in drawablePieces) {
        NSInteger nonWhitespaceLength = [drawablePiece stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet].length;
        if (shouldBeWhitespace) {
            XCTAssertEqual(nonWhitespaceLength, 0);
        } else {
            XCTAssertNotEqual(nonWhitespaceLength, 0);
        }
        shouldBeWhitespace = !shouldBeWhitespace;
    }
}

#pragma mark - mapTextSections:toDrawablePieces:

- (void)testMapTextSectionsToDrawablePieces_correctLength {
    self.textForTouchableLabel = @[@"Hello ", @"world!"];
    NSArray* drawablePieces = @[@"Hello", @" ", @"world!"];
    NSArray* textSectionsToDrawablePieces = [self.touchableLabel mapTextSections:self.textForTouchableLabel toDrawablePieces:drawablePieces];
    XCTAssertEqual(drawablePieces.count, textSectionsToDrawablePieces.count);
}

#pragma mark - sizeForDrawablePiece:withTextSectionChunks:

- (void)testSizeForDrawablePieceWithTextSectionChunks_emptyInput {
    CGSize size = [self.touchableLabel sizeForDrawablePiece:@"" withTextSectionChunks:@[]];
    XCTAssertEqual(size.width, 0.0f);
    XCTAssertEqual(size.height, 0.0f);
}

#pragma mark - drawTextInRect:

- (void)testDrawTextInRect_performance {
    NSString* loremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet nibh massa, id facilisis arcu malesuada nec. Integer scelerisque dolor in nibh aliquam consequat. Fusce sit amet velit quis felis commodo consequat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec sagittis condimentum neque et dictum. Sed tristique consectetur eros, quis interdum nisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. Vivamus ultricies imperdiet elit id vehicula. Aliquam vulputate urna et sem aliquet efficitur. Aenean urna mi, gravida in sem sollicitudin, auctor feugiat massa. In quis gravida nulla. In eu auctor justo Maecenas id placerat erat. Integer at augue bibendum, rutrum turpis sed, egestas nibh. Maecenas non elit est. Sed vehicula, ligula sed lobortis vulputate, lectus dolor varius erat, in accumsan elit nulla ac lectus. Proin bibendum lobortis gravida. Duis viverra quam id cursus auctor. Duis turpis purus, ullamcorper at lacus sit amet, pellentesque consequat metus. Nullam ut erat leo. Phasellus pulvinar sem vitae augue dapibus imperdiet. Mauris id feugiat enim, id auctor nisl. Donec eget nisl porta justo condimentum pretium sit amet sed sem. Etiam sit amet ex sed magna feugiat accumsan. Phasellus non massa vel nisi dignissim sagittis. Quisque gravida aliquet diam vel imperdiet. Proin dui orci, rutrum vitae arcu at, efficitur molestie quam. Donec feugiat massa ac metus rutrum, vel maximus lectus vulputate. Curabitur ultrices leo massa, vitae facilisis dui ultrices eu. Nunc nec dignissim justo, aliquam mattis tortor. Nunc augue libero, laoreet id pellentesque sit amet, tincidunt ac est. Fusce at dictum erat. Ut tempus congue efficitur. Fusce nec tortor eu ante vestibulum iaculis eu sed velit. Proin pretium quam in nunc condimentum, sollicitudin gravida orci maximus. Nunc eu rhoncus risus. Etiam est orci, maximus non elit eu, sollicitudin vestibulum lorem. Praesent eget lectus quam. Donec accumsan congue lacus, in malesuada ipsum molestie aliquet. Praesent vehicula ex sit amet erat aliquet aliquam. Ut non tempus magna, ornare ultricies mauris. In suscipit diam vel augue varius, in fermentum massa dictum. Nunc arcu est, vulputate eget libero eu, tristique malesuada ipsum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae egestas odio, sit amet mattis est. Proin vel nibh quis mauris euismod feugiat. Ut sagittis accumsan mauris. Ut pharetra convallis tellus eget cursus. Integer ut metus mauris. Aenean dictum ante non efficitur iaculis. Nam at leo viverra, volutpat velit eu, placerat libero. Donec mi diam, iaculis non libero sed, pulvinar commodo enim. Fusce in rutrum lectus. Nulla porttitor dolor dui, a tincidunt lorem molestie quis. Vivamus nec consectetur odio. Donec non risus augue. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed dignissim ex vel sapien vulputate, ac tempor urna ultrices. Donec volutpat ipsum vel ex maximus convallis. In eu leo eu erat blandit eleifend eget ut nisi.";
    NSString* inputText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum, loremIpsum];
    self.textForTouchableLabel = [inputText componentsSeparatedByString:@" "];
    
    [self measureBlock:^{
        [self.touchableLabel drawTextInRect:self.view.bounds];
    }];
}

#pragma mark - MSPTouchableLabelDataSource

- (NSArray*)textForTouchableLabel:(MSPTouchableLabel*)touchableLabel {
    return self.textForTouchableLabel;
}

@end
