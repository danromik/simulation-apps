//
//  ASMView.m
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import "ASMView.h"

#define kCircleColor			[NSColor blueColor]
#define kCPLimitShapeColor		[NSColor colorWithCalibratedRed:0.3 green:0 blue:0.4 alpha:1]
#define kEntryOneColor			[NSColor blackColor]
#define kEntryMinusOneColor		[NSColor colorWithCalibratedRed:0.7 green:0 blue:0 alpha:1]
#define kEntryOneStrokeFillAction		fill
#define kEntryMinusOneStrokeFillAction	fill
#define kEntryZeroTraditionalColor				[NSColor grayColor]
#define kEntryMinusOneTraditionalColor			[NSColor colorWithCalibratedRed:0.3 green:0 blue:0 alpha:1]
#define kEntryOneTraditionalColor				[NSColor blackColor]
#define kGridColor						[NSColor grayColor]
#define kFontNameTraditional			@"Courier"
#define kFontNameMonotoneTriangleNormal	@"Courier"
#define kFontNameMonotoneTriangleFrozen	@"Courier Bold"
#define kMonotoneTriangleFrozenColor	[NSColor colorWithCalibratedRed:0.1 green:0.2 blue:0.6 alpha:1]

#define kUpArrowColor			[NSColor blackColor]
#define kDownArrowColor			[NSColor colorWithCalibratedRed:0.1 green:0.2 blue:0.6 alpha:1]
#define kLeftArrowColor			[NSColor blackColor]
#define kRightArrowColor		[NSColor blackColor]

#define kAutomaticHighQualityOutputOrderThreshold		100

@implementation ASMView

- (bool)toggleOn
{
	return self.highlightDownArrows;
}

- (void)setToggleOn:(bool)newToggle
{
	if (self.toggleOn != newToggle) {
		self.highQualityOutput = !self.highQualityOutput;
		self.highlightDownArrows = !self.highlightDownArrows;		
		[self toggleMonotoneTriangleFitToGrid];
	}
}

- (void)takeViewTypeFromRadioButton:(NSMatrix *)radio
{
	self.viewType = [radio selectedRow];
}

- (ViewType)viewType
{
	return viewType;
}

- (void)setViewType:(ViewType)newType
{
	if (viewType != newType) {
		viewType = newType;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)monotoneTriangleFitToGrid
{
	return monotoneTriangleFitToGrid;
}

- (void)setMonotoneTriangleFitToGrid:(bool)newValue
{
	if (monotoneTriangleFitToGrid != newValue) {
		monotoneTriangleFitToGrid = newValue;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)highlightMTFrozenRegion;
{
	return highlightMTFrozenRegion;
}

- (void)setHighlightMTFrozenRegion:(bool)new
{
	if (highlightMTFrozenRegion != new) {
		highlightMTFrozenRegion = new;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)highlightDownArrows;
{
	return highlightDownArrows;
}

- (void)setHighlightDownArrows:(bool)new
{
	if (highlightDownArrows != new) {
		highlightDownArrows = new;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)circleOn
{
	return circleOn;
}

- (void)setCircleOn:(bool)newOn
{
	if (circleOn != newOn) {
		circleOn = newOn;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)CPLimitShapeOn
{
	return CPLimitShapeOn;
}

- (void)setCPLimitShapeOn:(bool)newOn
{
	if (CPLimitShapeOn != newOn) {
		CPLimitShapeOn = newOn;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)gridOn
{
	return gridOn;
}

- (void)setGridOn:(bool)newOn
{
	if (gridOn != newOn) {
		gridOn = newOn;
		[self setNeedsDisplay:TRUE];
	}
}

- (bool)highQualityOutput
{
	return highQualityOutput;
}

- (void)setHighQualityOutput:(bool)newOn
{
	if (highQualityOutput != newOn) {
		highQualityOutput = newOn;
		[self setNeedsDisplay:TRUE];
	}
}

- (ASM *)myASM
{
	return myASM;
}


- (void)setMyASM:(ASM *)newASM
{
	[myASM release];
	myASM = [newASM retain];
	[self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	NSRect bounds = self.bounds;
	int order = myASM.order;
	if (order == 0)
		return;
	
	NSPoint offset;
	CGFloat unit;
	if (bounds.size.width < bounds.size.height) {
		offset.x = 0;
		offset.y = (bounds.size.height - bounds.size.width)/2;
		unit = bounds.size.width / order;
	}
	else {
		offset.y = 0;
		offset.x = (bounds.size.width - bounds.size.height)/2;		
		unit = bounds.size.height / order;
	}	
	
	[[NSColor grayColor] set];
	NSFrameRect(NSMakeRect(offset.x, offset.y, order*unit, order*unit));
	
	int i,j;
	NSBezierPath *path;
	
	if (gridOn) {
		[kGridColor	set];
		path = [NSBezierPath bezierPath];
		for (i=1; i<order; i++) {
			[path moveToPoint:NSMakePoint(offset.x + i*unit, offset.y)];
			[path lineToPoint:NSMakePoint(offset.x + i*unit, offset.y + order * unit)];
			[path moveToPoint:NSMakePoint(offset.x, offset.y + i*unit)];
			[path lineToPoint:NSMakePoint(offset.x + order*unit, offset.y + i*unit)];
		}
		[path stroke];
	}
		
	bool shouldDrawHighQualityOutput = (highQualityOutput || order < kAutomaticHighQualityOutputOrderThreshold);
	NSRect entryRect;
	
	switch (viewType) {
		case ASMViewTypeDisks:
			goto ViewTypeDisks;
		case ASMViewTypeTraditional:
			goto ViewTypeTraditional;
		case ASMViewTypeSquareIce:
			goto ViewTypeSquareIce;
		case ASMViewTypeCornerSum:
			goto ViewTypeCornerSum;
		case ASMViewTypeColumnSum:
			goto ViewTypeColumnSum;
		case ASMViewTypeMonotoneTriangle:
			goto ViewTypeMonotoneTriangle;
		case ASMViewTypeSkewedSummation:
			goto ViewTypeSkewedSummation;
		case ASMViewTypeColoring:
			goto ViewTypeThreeColoring;
		case ASMViewTypeFullyPackedLoops:
			goto ViewTypeFullyPackedLoops;
	}
	
ReturnHere:
	if (circleOn) {
		[kCircleColor set];
		path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(offset.x, offset.y, order * unit, order * unit)];
		[path setLineWidth:2];
		[path stroke];
	}
	if (CPLimitShapeOn) {
		[kCPLimitShapeColor set];
#define kNumCPLimitShapePoints	100
		NSBezierPath *cpPath = [NSBezierPath bezierPath];
		[cpPath moveToPoint:NSMakePoint(offset.x + order*unit/2, offset.y + order*unit)];
		for (i=0; i<=kNumCPLimitShapePoints; i++) {
			float x, y;
			x = (float)i/(float)kNumCPLimitShapePoints;
			y = (1-x+sqrtf(1+2*x-3*x*x))/2.0;
			x = (x + 1)/2;
			y = (y + 1)/2;
			[cpPath lineToPoint:NSMakePoint(offset.x+unit*order*x, offset.y + unit*order*y)];
		}
//		[cpPath stroke];	
//		cpPath = [NSBezierPath bezierPath];
//		[cpPath moveToPoint:NSMakePoint(offset.x + order*unit/2, bounds.size.height - offset.y + order*unit)];
		for (i=kNumCPLimitShapePoints; i>=0; i--) {
			float x, y;
			x = (float)i/(float)kNumCPLimitShapePoints;
			y = (1-x+sqrtf(1+2*x-3*x*x))/2.0;
			x = (x + 1)/2;
			y = (y + 1)/2;
			[cpPath lineToPoint:NSMakePoint(offset.x+unit*order*x, bounds.size.height - offset.y - unit*order*y)];
		}
		for (i=kNumCPLimitShapePoints; i>=0; i--) {
			float x, y;
			x = (float)i/(float)kNumCPLimitShapePoints;
			y = (1-x+sqrtf(1+2*x-3*x*x))/2.0;
			x = (x + 1)/2;
			y = (y + 1)/2;
			[cpPath lineToPoint:NSMakePoint(bounds.size.width - offset.x -unit*order*y, bounds.size.height - offset.y - unit*order*x)];
		}
		for (i=kNumCPLimitShapePoints; i>=0; i--) {
			float x, y;
			x = (float)i/(float)kNumCPLimitShapePoints;
			y = (1-x+sqrtf(1+2*x-3*x*x))/2.0;
			x = (x + 1)/2;
			y = (y + 1)/2;
			[cpPath lineToPoint:NSMakePoint(bounds.size.width - offset.x - unit*order*x, offset.y + unit*order*y)];
		}
		[cpPath setLineWidth:2.0];
		[cpPath stroke];
	}
	return;
	
ViewTypeDisks:
	for (i=0; i<order; i++)
		for (j=0; j<order; j++) {
			switch ([myASM entryInRow:i column:j]) {
				case -1:
					[kEntryMinusOneColor set];
					entryRect = NSMakeRect(offset.x+((float)j+0.2)*unit, bounds.size.height-offset.y-((float)i+0.8)*unit, 0.6*unit, 0.6*unit);
					if (shouldDrawHighQualityOutput) {
						path = [NSBezierPath bezierPathWithOvalInRect:entryRect];
						[path kEntryMinusOneStrokeFillAction];
					}
					else
						NSRectFill(entryRect);
					break;
				case 1:
					[kEntryOneColor set];
					entryRect = NSMakeRect(offset.x+((float)j+0.2)*unit, bounds.size.height-offset.y-((float)i+0.8)*unit, 0.6*unit, 0.6*unit);
					if (shouldDrawHighQualityOutput) {
						path = [NSBezierPath bezierPathWithOvalInRect:entryRect];
						[path kEntryOneStrokeFillAction];
					}
					else
						NSRectFill(entryRect);
					break;
//				case 0:
//					[[NSColor colorWithCalibratedWhite:0.85 alpha:1] set];
//					[path stroke];
			}
		}
	goto ReturnHere;
	
ViewTypeTraditional:
#define kZeroString		@"0"
#define kOneString		@"1"
#define kMinusOneString	@"–1"
	[[NSColor blackColor] set];
	NSDictionary *attributesZero = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameTraditional size:roundf(unit/1.5)],NSFontAttributeName,
									kEntryZeroTraditionalColor, NSForegroundColorAttributeName,
									nil];
	NSDictionary *attributesMinusOne = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameTraditional size:roundf(unit/1.5)],NSFontAttributeName,
										kEntryMinusOneTraditionalColor, NSForegroundColorAttributeName,
										nil];
	NSDictionary *attributesOne = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameTraditional size:roundf(unit/1.5)],NSFontAttributeName,
								   kEntryOneTraditionalColor, NSForegroundColorAttributeName,
								   nil];
	NSSize textSizeZero = [kZeroString sizeWithAttributes:attributesOne];
	NSSize textSizeOne = [kOneString sizeWithAttributes:attributesOne];
	NSSize textSizeMinusOne = [kMinusOneString sizeWithAttributes:attributesOne];
	NSSize actualSize;
	NSString *actualText;
	NSDictionary *actualAttributes;
	for (i=0; i<order; i++)
		for (j=0; j<order; j++) {
			switch ([myASM entryInRow:i column:j]) {
				case -1:
					actualSize = textSizeMinusOne;
					actualText = kMinusOneString;
					actualAttributes = attributesMinusOne;
					break;
				case 1:
					actualSize = textSizeOne;
					actualText = kOneString;
					actualAttributes = attributesOne;
					break;
				case 0:
					actualSize = textSizeZero;
					actualText = kZeroString;
					actualAttributes = attributesZero;
			}
			entryRect = NSMakeRect(offset.x+((float)j+0.5)*unit-actualSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-actualSize.height/2, 
								   actualSize.width, actualSize.height);
			[actualText drawInRect:entryRect withAttributes:actualAttributes];
		}
	goto ReturnHere;
	
ViewTypeSquareIce:
	unit = unit*order / (order+1);
	
	if (highlightDownArrows)
		[[NSColor grayColor] set];
	else
		[[NSColor blackColor] set];
	int sum;
	path = [NSBezierPath bezierPath];
	for (i=0; i<order; i++) {
		for (j=0; j<order; j++) {
			entryRect = NSMakeRect(offset.x+((float)j+0.9)*unit, bounds.size.height-offset.y-((float)i+1.1)*unit, 0.2*unit, 0.2*unit);
			[path appendBezierPathWithOvalInRect:entryRect];
		}
	}
	[path fill];
//	path = [NSBezierPath bezierPath];
//	for (i=0; i<order; i++) {
//		for (j=0; j<order+1; j++) {
//			[path moveToPoint:NSMakePoint(offset.x+(j+0.25)*unit, offset.y+(i+1)*unit)];
//			[path lineToPoint:NSMakePoint(offset.x+(j+0.75)*unit, offset.y+(i+1)*unit)];
//		}
//	}
//	for (i=0; i<order+1; i++) {
//		for (j=0; j<order; j++) {
//			[path moveToPoint:NSMakePoint(offset.x+(j+1)*unit,offset.y+(i+0.25)*unit)];
//			[path lineToPoint:NSMakePoint(offset.x+(j+1)*unit,offset.y+(i+0.75)*unit)];
//		}
//	}
//	[path stroke];

	for (i=0; i<order; i++) {
		sum = 0;
		for (j=0; j<order+1; j++) {
			if (sum == 1) {
				if (highlightDownArrows)
					[[NSColor grayColor] set];
				else
					[kLeftArrowColor set];
				path = [NSBezierPath bezierPath];
				[path moveToPoint:NSMakePoint(offset.x+(j+0.25)*unit, bounds.size.height-offset.y-(i+1)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+0.45)*unit, bounds.size.height-offset.y-(i+1.05)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+0.45)*unit, bounds.size.height-offset.y-(i+0.95)*unit)];
				[path closePath];
				[path fill];
			}
			else {
				if (highlightDownArrows)
					[[NSColor grayColor] set];
				else
					[kRightArrowColor set];
				path = [NSBezierPath bezierPath];
				[path moveToPoint:NSMakePoint(offset.x+(j+0.75)*unit, bounds.size.height-offset.y-(i+1)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+0.55)*unit, bounds.size.height-offset.y-(i+1.05)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+0.55)*unit, bounds.size.height-offset.y-(i+0.95)*unit)];
				[path closePath];
				[path fill];
			}
			path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(offset.x+(j+0.25)*unit, bounds.size.height-offset.y-(i+1)*unit)];
			[path lineToPoint:NSMakePoint(offset.x+(j+0.75)*unit, bounds.size.height-offset.y-(i+1)*unit)];
			[path stroke];			
			if (i<order && j<order)
				sum = sum + [myASM entryInRow:i column:j];
		}
	}

	for (j=0; j<order; j++) {
		sum = 0;
		for (i=0; i<order+1; i++) {
			if (sum == 0) {
				if (highlightDownArrows)
					[[NSColor grayColor] set];
				else
					[kUpArrowColor set];
				path = [NSBezierPath bezierPath];
				[path moveToPoint:NSMakePoint(offset.x+(j+1)*unit,bounds.size.height-offset.y-(i+0.25)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+1.05)*unit,bounds.size.height-offset.y-(i+0.45)*unit)];
				[path lineToPoint:NSMakePoint(offset.x+(j+0.95)*unit,bounds.size.height-offset.y-(i+0.45)*unit)];
				[path closePath];
				[path fill];
			}
			else {
				path = [NSBezierPath bezierPath];
				if (highlightDownArrows) {
					[kDownArrowColor set];
					[path moveToPoint:NSMakePoint(offset.x+(j+1)*unit,bounds.size.height-offset.y-(i+0.75)*unit-5)];
					[path lineToPoint:NSMakePoint(offset.x+(j+1.12)*unit,bounds.size.height-offset.y-(i+0.55)*unit)];
					[path lineToPoint:NSMakePoint(offset.x+(j+0.88)*unit,bounds.size.height-offset.y-(i+0.55)*unit)];					
				}
				else {
					[kUpArrowColor set];
					[path moveToPoint:NSMakePoint(offset.x+(j+1)*unit,bounds.size.height-offset.y-(i+0.75)*unit)];
					[path lineToPoint:NSMakePoint(offset.x+(j+1.05)*unit,bounds.size.height-offset.y-(i+0.55)*unit)];
					[path lineToPoint:NSMakePoint(offset.x+(j+0.95)*unit,bounds.size.height-offset.y-(i+0.55)*unit)];
				}
				[path closePath];
				[path fill];
			}
			path = [NSBezierPath bezierPath];
			if (sum==1 && highlightDownArrows)
				[path setLineWidth:4];
			[path moveToPoint:NSMakePoint(offset.x+(j+1)*unit,bounds.size.height-offset.y-(i+0.25)*unit)];
			[path lineToPoint:NSMakePoint(offset.x+(j+1)*unit,bounds.size.height-offset.y-(i+0.75)*unit)];
			[path stroke];
			if (i<order && j<order)
				sum = sum + [myASM entryInRow:i column:j];
		}
	}
	goto ReturnHere;
	
ViewTypeMonotoneTriangle: ;
	Matrix *cornerSum = [myASM cornerSumMatrix];
	[[NSColor blackColor] set];
	NSDictionary *attributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont 
																				 fontWithName:kFontNameMonotoneTriangleNormal 
																				 size:roundf(unit/1.5)],NSFontAttributeName,
									  [NSColor blackColor], NSForegroundColorAttributeName, nil];
	NSDictionary *attributesFrozen = (highlightMTFrozenRegion ? [NSDictionary dictionaryWithObjectsAndKeys:[NSFont 
																											fontWithName:kFontNameMonotoneTriangleFrozen 
																											size:roundf(unit/1.35)],NSFontAttributeName,
																 kMonotoneTriangleFrozenColor, NSForegroundColorAttributeName, nil] : attributesNormal);
	int k;
	NSString *valueString;
	NSSize stringSize;
	bool frozenRegion;
	
	float animationProgress = (currentAnimation ? [currentAnimation currentProgress] : 0);
	if (!monotoneTriangleFitToGrid)
		animationProgress = 1 - animationProgress;
	
	for (i=0; i<order; i++) {
		k = 1;
		for (j=0; j<order; j++) {
			int columnSum = [cornerSum entryInRow:i column:j] - (j>0 ? [cornerSum entryInRow:i column:j-1] : 0);
			switch (columnSum) {
				case 1:
					valueString = [NSString stringWithFormat:@"%d",j+1];
					frozenRegion = (j+1==k || j+1==k+order-i-1);
					stringSize = [valueString sizeWithAttributes:(frozenRegion ? attributesFrozen : attributesNormal)];
					float fitToGridOriginX = offset.x+((float)j+0.5)*unit-stringSize.width/2;
					float normalOriginX = offset.x+((float)k-1+(order-i)*0.5)*unit-stringSize.width/2;
					float originX = animationProgress * normalOriginX + (1-animationProgress) * fitToGridOriginX;
					entryRect = NSMakeRect(originX, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
										   stringSize.width, stringSize.height);
//					if (monotoneTriangleFitToGrid) {
//						entryRect = NSMakeRect(offset.x+((float)j+0.5)*unit-stringSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
//											   stringSize.width, stringSize.height);
//					}
//					else {
//						entryRect = NSMakeRect(offset.x+((float)k-1+(order-i)*0.5)*unit-stringSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
//											   stringSize.width, stringSize.height);						
//					}
					[valueString drawInRect:entryRect withAttributes:(frozenRegion ? attributesFrozen : attributesNormal)];
					k++;
					break;
				case 0:
					break;
			}
		}
	}
	goto ReturnHere;
	
ViewTypeCornerSum:
	unit = unit*order/(order+1);
	cornerSum = [myASM extendedCornerSumMatrix];
	[[NSColor blackColor] set];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameMonotoneTriangleNormal 
																						  size:roundf(unit/1.5)],NSFontAttributeName,
								[NSColor blackColor], NSForegroundColorAttributeName, nil];
	
	for (i=0; i<=order; i++) {
		for (j=0; j<=order; j++) {
			int entry = [cornerSum entryInRow:i column:j];
			valueString = [NSString stringWithFormat:@"%d",entry];
			stringSize = [valueString sizeWithAttributes:attributes];
			entryRect = NSMakeRect(offset.x+((float)j+0.5)*unit-stringSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
								   stringSize.width, stringSize.height);
			[valueString drawInRect:entryRect withAttributes:attributes];
		}
	}
	goto ReturnHere;
	
ViewTypeColumnSum: ;
	Matrix *columnSumMatrix = [myASM columnSumMatrix];
	[[NSColor blackColor] set];
	NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameMonotoneTriangleNormal 
																						   size:roundf(unit/1.5)],NSFontAttributeName,
								 [NSColor blackColor], NSForegroundColorAttributeName, nil];
	NSDictionary *attributes0 = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameMonotoneTriangleNormal 
																						   size:roundf(unit/1.5)],NSFontAttributeName,
								 [NSColor grayColor], NSForegroundColorAttributeName, nil];
	
	for (i=0; i<order; i++) {
		for (j=0; j<order; j++) {
			int entry = [columnSumMatrix entryInRow:i column:j];
			valueString = [NSString stringWithFormat:@"%d",entry];
			stringSize = [valueString sizeWithAttributes:attributes1];
			entryRect = NSMakeRect(offset.x+((float)j+0.5)*unit-stringSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
								   stringSize.width, stringSize.height);
			[valueString drawInRect:entryRect withAttributes:(entry == 1 ? attributes1 : attributes0)];
		}
	}
	goto ReturnHere;

ViewTypeSkewedSummation: ;
	Matrix *skewedSummationMatrix = [myASM skewedSummationMatrix];
	unit = unit*order/(order+1);
	[[NSColor blackColor] set];
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameMonotoneTriangleNormal 
																						  size:roundf(unit/1.5)],NSFontAttributeName,
								[NSColor blackColor], NSForegroundColorAttributeName, nil];
	
	for (i=0; i<=order; i++) {
		for (j=0; j<=order; j++) {
			int entry = [skewedSummationMatrix entryInRow:i column:j];
			valueString = [NSString stringWithFormat:@"%d",entry];
			stringSize = [valueString sizeWithAttributes:attributes];
			entryRect = NSMakeRect(offset.x+((float)j+0.5)*unit-stringSize.width/2, bounds.size.height-offset.y-((float)i+0.5)*unit-stringSize.height/2, 
								   stringSize.width, stringSize.height);
			[valueString drawInRect:entryRect withAttributes:attributes];
		}
	}
	goto ReturnHere;
	
ViewTypeThreeColoring: ;
	CGFloat colorComponents[3][4] = { 1,0.2,0.3,1, 0.3,1,0.2,1, 0.2,0.3,1,1 };
	Matrix *coloringMatrix = [myASM threeColoringMatrix];
	unit = unit*order/(order+1);
	[[NSColor blackColor] set];
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:kFontNameMonotoneTriangleNormal 
																			size:roundf(unit/1.5)],NSFontAttributeName,
				  [NSColor blackColor], NSForegroundColorAttributeName, nil];
	
	for (i=0; i<=order; i++) {
		for (j=0; j<=order; j++) {
			int entry = [coloringMatrix entryInRow:i column:j];
			[[NSColor colorWithCalibratedRed:colorComponents[entry][0]
									   green:colorComponents[entry][1] 
										blue:colorComponents[entry][2] 
									   alpha:colorComponents[entry][3]] set];
			if (highQualityOutput) {
				entryRect = NSMakeRect(offset.x+((float)j+0.2)*unit, bounds.size.height-offset.y-((float)i+0.8)*unit, 0.6*unit, 0.6*unit);
				path = [NSBezierPath bezierPathWithOvalInRect:entryRect];
				[path fill];
			}
			else {
				entryRect = NSMakeRect(offset.x+((float)j)*unit, bounds.size.height-offset.y-((float)i+1)*unit, unit, unit);
				NSRectFill(entryRect);
			}
		}
	}
	goto ReturnHere;
	
ViewTypeFullyPackedLoops:
	// *** add this later ***
	goto ReturnHere;
}

- (void)toggleMonotoneTriangleFitToGrid
{
//	if (viewType != ASMViewTypeMonotoneTriangle)
//		return;
	
	NSAnimationProgress progMarks[] = {
		0.025,0.05, 0.075,0.1,0.125, 0.15,0.175, 0.2,0.225, 0.25,0.275, 0.3,0.325, 0.35,0.375, 0.4,0.425, 0.45,0.475, 0.5,0.525,
	0.55,0.575, 0.6,0.625, 0.65,0.675, 0.7,0.725, 0.75,0.775, 0.8,0.825, 0.85,0.875, 0.9,0.925, 0.95,0.975, 1.0  };
	
	if (currentAnimation)
		[currentAnimation release];
	
    int i, count = 40;
    currentAnimation = [[NSAnimation alloc] initWithDuration:0.5 animationCurve:NSAnimationEaseIn];
    [currentAnimation setFrameRate:60];
    [currentAnimation setDelegate:self];
	[currentAnimation setAnimationBlockingMode:NSAnimationNonblocking];
    for (i=0; i<count; i++)
        [currentAnimation addProgressMark:progMarks[i]];
	[currentAnimation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	[currentAnimation release];
	currentAnimation = nil;
	self.monotoneTriangleFitToGrid = !self.monotoneTriangleFitToGrid;
}

- (void)animation:(NSAnimation *)animation didReachProgressMark:(NSAnimationProgress)progress
{
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if (!([theEvent modifierFlags] & (NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask))) {
		switch (viewType) {
			case ASMViewTypeSquareIce:	
				self.highlightDownArrows = !self.highlightDownArrows;
				break;
			case ASMViewTypeMonotoneTriangle:
				[self toggleMonotoneTriangleFitToGrid];
				break;
		}
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask)
		self.highQualityOutput = !self.highQualityOutput;
	else if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		switch (viewType) {
			case ASMViewTypeMonotoneTriangle:
				self.highlightMTFrozenRegion = !self.highlightMTFrozenRegion;
				break;
		}
	}
}


- (void)dealloc
{
	self.myASM = nil;
	[currentAnimation release];
	[super dealloc];
}

@end
