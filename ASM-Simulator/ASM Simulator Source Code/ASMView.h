//
//  ASMView.h
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ASM.h"

typedef enum {
	ASMViewTypeDisks = 0,
	ASMViewTypeTraditional,
	ASMViewTypeSquareIce,
	ASMViewTypeColumnSum,
	ASMViewTypeCornerSum,
	ASMViewTypeMonotoneTriangle,
	ASMViewTypeSkewedSummation,
	ASMViewTypeColoring,
	ASMViewTypeFullyPackedLoops
} ViewType;

@interface ASMView : NSView {
	ASM *myASM;
	bool circleOn;
	bool CPLimitShapeOn;
	bool highQualityOutput;
	bool gridOn;
	bool highlightDownArrows;
	bool highlightMTFrozenRegion;
	bool monotoneTriangleFitToGrid;
	
	ViewType viewType;
	NSAnimation *currentAnimation;
}
@property (readwrite, retain) ASM *myASM;
@property (readwrite) bool circleOn;			// a circle (limit shape of domino measure)
@property (readwrite) bool CPLimitShapeOn;		// the Colomo-Pronko limit shape
@property (readwrite) bool gridOn;
@property (readwrite) bool highQualityOutput;
@property (readwrite) bool highlightDownArrows;
@property (readwrite) bool highlightMTFrozenRegion;
@property (readwrite) bool monotoneTriangleFitToGrid;
@property (readwrite) bool toggleOn;							// unifies several of the toggles

@property (readwrite) ViewType viewType;

- (IBAction)takeViewTypeFromRadioButton:(NSMatrix *)radio;
- (void)toggleMonotoneTriangleFitToGrid;

@end
