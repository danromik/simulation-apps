//
//  ASM.h
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Matrix.h"

typedef enum {
	IceMoleculeHorizontal,
	IceMoleculeVertical,
	IceMoleculeNorthEast,
	IceMoleculeNorthWest,
	IceMoleculeSouthEast,
	IceMoleculeSouthWest
} IceMolecule;

@interface ASM : Matrix {
	int order;
}
@property (readonly) int order;

+ (ASM *)randomDominoASMOfOrder:(int)ord;

- (ASM *)initIdentityWithOrder:(int)ord;
- (ASM *)initWithCornerSumMatrix:(Matrix *)matrix;
- (ASM *)copy;

- (Matrix *)cornerSumMatrix;				// Returns the corner sum matrix
- (Matrix *)extendedCornerSumMatrix;		// Same as above but the order of this matrix is bigger by 1, the first row and columns are 0
- (Matrix *)columnSumMatrix;				// Returns the matrix with cumulative sums of the columns
- (Matrix *)rowSumMatrix;
- (Matrix *)skewedSummationMatrix;
- (Matrix *)threeColoringMatrix;
- (Matrix *)squareIceMatrix;

- (NSArray *)positionsOfOnes;				// Returns array of MatrixPositions encoded as NSValues
- (NSArray *)positionsOfMinusOnes;			// Returns array of MatrixPositions encoded as NSValues

- (ASM *)minimalShrinkageASM;				// Returns the compatible ASM of order one less than the receiver's order which has minimal corner growth matrix
- (ASM *)maximalGrowthASM;					// Returns the compatible ASM of order one more than the receiver's order which has maximal corner growth matrix

- (ASM *)randomShrinkageASM;
- (ASM *)randomGrowthASM;


@end
