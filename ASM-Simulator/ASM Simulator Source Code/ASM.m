//
//  ASM.m
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import "ASM.h"


@implementation ASM
@synthesize order;

- (ASM *)initIdentityWithOrder:(int)ord
{
	if (self = (ASM *)[super initWithRows:ord columns:ord]) {
		order = ord;
		int i;
		for (i=0; i<ord; i++)
			[self setEntryInRow:i column:i to:1];
	}
	return self;
}

+ (ASM *)randomDominoASMOfOrder:(int)ord
{
	ASM *mat = [[[ASM alloc] initIdentityWithOrder:1] autorelease];
	int i;
	for (i=0; i<ord-1; i++)
		mat = [mat randomGrowthASM];
	return mat;
}

- (ASM *)initWithCornerSumMatrix:(Matrix *)matrix
{
	order = matrix.rows;
	if (order != matrix.columns) {
		[self autorelease];
		return nil;
	}
	if (self = (ASM *)[super initWithRows:order columns:order]) {
		int i, j;
		for (i=0; i<order; i++)
			for (j=0; j<order; j++) {
				int up, left, diagonal, current;
				up = (i > 0 ? [matrix entryInRow:i-1 column:j] : 0);
				left = (j > 0 ? [matrix entryInRow:i column:j-1] : 0);
				diagonal = (i>0 && j>0 ? [matrix entryInRow:i-1 column:j-1] : 0);
				current = [matrix entryInRow:i column:j];
				[self setEntryInRow:i column:j to:current - up - left + diagonal];
			}
	}
	return self;
}

- (ASM *)copy
{
	ASM *mat = [[ASM alloc] initIdentityWithOrder:order];
	int i,j;
	for (i=0; i<rows; i++)
		for (j=0; j<columns; j++)
			[mat setEntryInRow:i column:j to:[self entryInRow:i column:j]];
	return mat;
}

- (Matrix *)cornerSumMatrix
{
	Matrix *mat = [[Matrix alloc] initWithRows:order columns:order];
	int i,j;
	for (i=0; i < order; i++)
		for (j=0; j< order; j++) {
			int up, left, diagonal, current;
			up = (i > 0 ? [mat entryInRow:i-1 column:j] : 0);
			left = (j > 0 ? [mat entryInRow:i column:j-1] : 0);
			diagonal = (i>0 && j>0 ? [mat entryInRow:i-1 column:j-1] : 0);
			current = [self entryInRow:i column:j];
			[mat setEntryInRow:i column:j to:current + up + left - diagonal];
		}
	return [mat autorelease];
}

- (Matrix *)extendedCornerSumMatrix
{
	Matrix *mat = [[Matrix alloc] initWithRows:order+1 columns:order+1];
	Matrix *cornerSumMatrix = [self cornerSumMatrix];
	int i,j;
	for (i=0; i<order; i++)
		for (j=0; j<order; j++)
			[mat setEntryInRow:i+1 column:j+1 to:[cornerSumMatrix entryInRow:i column:j]];
	return [mat autorelease];
}

- (Matrix *)skewedSummationMatrix
{
	Matrix *mat = [self extendedCornerSumMatrix];
	int i,j;
	for (i=0; i <= order; i++)
		for (j=0; j<= order; j++) {
			[mat setEntryInRow:i column:j to:i+j-2*[mat entryInRow:i column:j]];
		}
	return mat;
}

- (Matrix *)threeColoringMatrix
{
	Matrix *skewedSummationMatrix = [self skewedSummationMatrix];
	Matrix *mat = [[Matrix alloc] initWithRows:order+1 columns:order+1];
	int i,j;
	for (i=0; i <= order; i++)
		for (j=0; j<= order; j++) {
			[mat setEntryInRow:i column:j to:[skewedSummationMatrix entryInRow:i column:j]%3];
		}
	return [mat autorelease];
}


- (Matrix *)columnSumMatrix
{
	Matrix *mat = [[Matrix alloc] initWithRows:order columns:order];
	int i,j, columnSum;
	for (j=0; j < order; j++) {
		columnSum = 0;
		for (i=0; i< order; i++) {
			columnSum = columnSum + [self entryInRow:i column:j];
			[mat setEntryInRow:i column:j to:columnSum];
		}
	}
	return [mat autorelease];
}

- (Matrix *)rowSumMatrix
{
	Matrix *mat = [[Matrix alloc] initWithRows:order columns:order];
	int i,j, rowSum;
	for (i=0; i < order; i++) {
		rowSum = 0;
		for (j=0; j< order; j++) {
			rowSum = rowSum + [self entryInRow:i column:j];
			[mat setEntryInRow:i column:j to:rowSum];
		}
	}
	return [mat autorelease];
}

- (Matrix *)squareIceMatrix
{
	Matrix *mat = [[Matrix alloc] initWithRows:order columns:order];
	Matrix *rowSumMatrix = [self rowSumMatrix];
	Matrix *columnSumMatrix = [self columnSumMatrix];
	int i,j;
	IceMolecule currentMolecule;
	for (i=0; i < order; i++) {
		for (j=0; j < order; j++) {
			switch ([self entryInRow:i column:j]) {
				case 1:
					currentMolecule = IceMoleculeHorizontal;
					break;
				case -1:
					currentMolecule = IceMoleculeVertical;
					break;
				case 0:
					if ([columnSumMatrix entryInRow:i column:j] == 0) {
						if ([rowSumMatrix entryInRow:i column:j] == 0)
							currentMolecule = IceMoleculeNorthEast;
						else
							currentMolecule = IceMoleculeNorthWest;
					}
					else {
						if ([rowSumMatrix entryInRow:i column:j] == 0)
							currentMolecule = IceMoleculeSouthEast;
						else
							currentMolecule = IceMoleculeSouthWest;
					}
					break;
			}
			[mat setEntryInRow:i column:j to:currentMolecule];
		}
	}
	return [mat autorelease];
}

- (NSArray *)positionsOfOnes
{
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
	MatrixPosition pos;
	for (pos.row=0; pos.row<order; pos.row++)
		for (pos.col=0; pos.col<order; pos.col++) {
			if ([self entryInRow:pos.row column:pos.col] == 1)
				[array addObject:[NSValue valueWithBytes:&pos objCType:@encode(MatrixPosition)]];
		}
	return [array autorelease];
}

- (NSArray *)positionsOfMinusOnes
{
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
	MatrixPosition pos;
	for (pos.row=0; pos.row<order; pos.row++)
		for (pos.col=0; pos.col<order; pos.col++) {
			if ([self entryInRow:pos.row column:pos.col] == -1)
				[array addObject:[NSValue valueWithBytes:&pos objCType:@encode(MatrixPosition)]];
		}
	return [array autorelease];	
}

- (ASM *)minimalShrinkageASM
{
	Matrix *minimalShrinkageCornerSumMatrix = [[[Matrix alloc] initWithRows:order-1 columns:order-1] autorelease];
	Matrix *cornerSum = [self cornerSumMatrix];
	int i,j;
	for (i=0; i<order-1; i++)
		for (j=0; j<order-1; j++)
			[minimalShrinkageCornerSumMatrix setEntryInRow:i column:j to:intmax([cornerSum entryInRow:i column:j],[cornerSum entryInRow:i+1 column:j+1]-1)];
	return [[[ASM alloc] initWithCornerSumMatrix:minimalShrinkageCornerSumMatrix] autorelease];	
}

- (ASM *)maximalGrowthASM
{
	Matrix *maximalGrowthCornerSumMatrix = [[[Matrix alloc] initWithRows:order+1 columns:order+1] autorelease];
	Matrix *cornerSum = [self cornerSumMatrix];
	int i,j;
	for (i=0; i<order+1; i++)
		for (j=0; j<order+1; j++) {
			if (i<order && j<order)
				[maximalGrowthCornerSumMatrix setEntryInRow:i column:j to:intmin([cornerSum entryInRow:i column:j],
				 (i == 0 || j==0 ? 1 : [cornerSum entryInRow:i-1 column:j-1]+1))];
			else
				[maximalGrowthCornerSumMatrix setEntryInRow:i column:j to:intmin(i,j)+1];
		}
	return [[[ASM alloc] initWithCornerSumMatrix:maximalGrowthCornerSumMatrix] autorelease];
}

- (ASM *)randomShrinkageASM
{
	NSArray *shrinkagePositions = [self positionsOfMinusOnes];
	ASM *shrunkASM = [self minimalShrinkageASM];
	for (NSValue *positionValue in shrinkagePositions) {
		MatrixPosition pos;
		[positionValue getValue:&pos];
		if ((bool)(random()&1)) {
			[shrunkASM setEntryInRow:pos.row column:pos.col to:[shrunkASM entryInRow:pos.row column:pos.col]+1];
			[shrunkASM setEntryInRow:pos.row-1 column:pos.col-1 to:[shrunkASM entryInRow:pos.row-1 column:pos.col-1]+1];
			[shrunkASM setEntryInRow:pos.row column:pos.col-1 to:[shrunkASM entryInRow:pos.row column:pos.col-1]-1];
			[shrunkASM setEntryInRow:pos.row-1 column:pos.col to:[shrunkASM entryInRow:pos.row-1 column:pos.col]-1];
		}
	}
	return [shrunkASM autorelease];
}

- (ASM *)randomGrowthASM
{
	NSArray *growthPositions = [self positionsOfOnes];
	ASM *grownASM = [self maximalGrowthASM];
//	NSLog(@"grownASM=\n%@",[grownASM description]);
//	NSLog(@"cornersum=\n%@",[[grownASM cornerSumMatrix] description]);
	for (NSValue *positionValue in growthPositions) {
		MatrixPosition pos;
		[positionValue getValue:&pos];
//		NSLog(@"%d %d",pos.row, pos.col);
		if ((bool)(random()&1)) {
//			NSLog(@"growing,\n%@",[grownASM description]);
			[grownASM setEntryInRow:pos.row column:pos.col to:[grownASM entryInRow:pos.row column:pos.col]-1];
			[grownASM setEntryInRow:pos.row+1 column:pos.col+1 to:[grownASM entryInRow:pos.row+1 column:pos.col+1]-1];
			[grownASM setEntryInRow:pos.row column:pos.col+1 to:[grownASM entryInRow:pos.row column:pos.col+1]+1];
			[grownASM setEntryInRow:pos.row+1 column:pos.col to:[grownASM entryInRow:pos.row+1 column:pos.col]+1];
		}
	}
	return grownASM;
}



@end
