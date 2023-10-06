//
//  Matrix.h
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kMatrixMaxRowCol			5000

int intmax(int a, int b);
int intmin(int a, int b);

typedef struct {
	int row;
	int col;	
} MatrixPosition;

@interface Matrix : NSObject {
	NSMutableData *data;
	int rows, columns;
}
@property (readonly) int rows, columns;

- (Matrix *)initWithRows:(int)numRows columns:(int)numColumns;

- (int)entryInRow:(int)row column:(int)col;
- (void)setEntryInRow:(int)row column:(int)col to:(int)value;

- (Matrix *)copy;

- (NSString *)description;

@end
