//
//  AztecTiling.h
//  ASM-Sim
//
//  Created by Dan Romik on 6/26/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// The Aztec graph of order n has 2n+1 rows. The even rows (starting with 0) have n columns and the odd rows have n+1 columns
typedef struct {
	int row;
	int column;
} AztecGraphVertex;

@class ASM;

@interface AztecTiling : NSObject {
	int order;
	NSMutableData *data;
}
@property (readonly) int order;

- (AztecTiling *)initTrivialTilingWithOrder:(int)ord;
- (AztecTiling *)initWithBigASM:(ASM *)bigASM smallASM:(ASM *)smallASM;

- (AztecGraphVertex)partnerOfVertex:(AztecGraphVertex)vertex;	// returns vertex coupled with a given vertex
- (void)partnerVertex:(AztecGraphVertex)vertex with:(AztecGraphVertex)partnerVertex;	// used when creating the tiling

- (bool)hasPartnerFor:(AztecGraphVertex)vertex;



@end
