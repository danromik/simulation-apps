//
//  Matrix.m
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import "Matrix.h"

int intmax(int a, int b)
{
	return (a > b ? a : b);
}

int intmin(int a, int b)
{
	return (a < b ? a : b);
}


@implementation Matrix
@synthesize rows, columns;

- (Matrix *)initWithRows:(int)numRows columns:(int)numColumns
{
	if (self = [super init]) {
		rows = (numRows < 0 ? 0 : (numRows > kMatrixMaxRowCol ? kMatrixMaxRowCol : numRows));
		columns = (numColumns < 0 ? 0 : (numColumns > kMatrixMaxRowCol ? kMatrixMaxRowCol : numColumns));
		data = [[NSMutableData alloc] initWithLength:rows*columns*sizeof(int)];
	}
	return self;
}

- (int)entryInRow:(int)row column:(int)col
{
	return ((int *)[data bytes])[row * columns + col];
}

- (void)setEntryInRow:(int)row column:(int)col to:(int)value
{
	((int *)[data mutableBytes])[row * columns + col] = value;
}

- (Matrix *)copy
{
	Matrix *mat = [[Matrix alloc] initWithRows:rows columns:columns];
	int i,j;
	for (i=0; i<rows; i++)
		for (j=0; j<columns; j++)
			[mat setEntryInRow:i column:j to:[self entryInRow:i column:j]];
	return mat;
}

- (NSString *)description
{
	NSMutableString *desc = [[NSMutableString alloc] initWithCapacity:0];
	int i,j;
	[desc appendFormat:@"Matrix of order %dx%d\n", rows, columns];
	for (i=0; i<rows; i++) {
		[desc appendString:@"| "];
		for (j=0; j<columns; j++)
			[desc appendFormat:@"%d ",[self entryInRow:i column:j]];
		[desc appendString:@"|\n"];
	}
	return [desc autorelease];
}

- (void)dealloc
{
	[data release];
	[super dealloc];
}


@end
