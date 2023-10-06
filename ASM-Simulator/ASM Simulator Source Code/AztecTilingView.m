//
//  AztecTilingView.m
//  ASM-Sim
//
//  Created by Dan Romik on 6/27/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Quartz/Quartz.h>


#import "AztecTilingView.h"
#import	"AztecTiling.h"


@implementation AztecTilingView

- (bool)grid
{
	return grid;
}

- (void)setGrid:(bool)value
{
	if (value != grid) {
		grid = value;
		[self setNeedsDisplay:YES];
	}
}

- (bool)rotated
{
	return rotated;
}

- (void)setRotated:(bool)value
{
	if (value != rotated) {
		rotated = value;
		[self setNeedsDisplay:YES];
	}
}

- (bool)circle
{
	return circle;
}

- (void)setCircle:(bool)value
{
	if (value != circle) {
		circle = value;
		[self setNeedsDisplay:YES];
	}
}

- (bool)colorful
{
	return colorful;
}

- (void)setColorful:(bool)value
{
	if (value != colorful) {
		colorful = value;
		[self setNeedsDisplay:YES];
	}
}

- (void)takeGridFrom:(NSButton *)checkbox
{
	self.grid = ([checkbox state] == NSOnState);
}

- (void)takeCircleFrom:(NSButton *)checkbox
{
	self.circle = ([checkbox state] == NSOnState);
}

- (void)takeColorfulFrom:(NSButton *)checkbox
{
	self.colorful = ([checkbox state] == NSOnState);
}

- (void)takeRotatedFrom:(NSButton *)checkbox
{
	self.rotated = ([checkbox state] == NSOnState);
}

- (AztecTiling *)tiling
{
	return tiling;
}

- (void)setTiling:(AztecTiling *)newTiling
{
	[tiling release];
	tiling = [newTiling retain];
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
	int order = tiling.order;
	if (order == 0)
		return;
	
	// reflect the y coordinate
	NSAffineTransform *transform = [NSAffineTransform transform];
	if (rotated) {
		[transform translateXBy:bounds.size.width/2 yBy:bounds.size.height/2];
		[transform rotateByDegrees:45];
		[transform scaleXBy:1/sqrtf(2.0) yBy:1/sqrtf(2.0)];
		[transform translateXBy:-bounds.size.width/2 yBy:-bounds.size.height/2];
	}
	[transform scaleXBy:1 yBy:-1];
	[transform translateXBy:0 yBy:-bounds.size.height];
	
	
	float minSize = (bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height);
	float unit =  minSize / (order+1.0);
	NSPoint origin = NSMakePoint((bounds.size.width - minSize)/2, (bounds.size.height - minSize)/2);
	[transform translateXBy:origin.x yBy:origin.y];
	
	[transform concat];
	
	AztecGraphVertex u, v;
	int i,j;
	int numVerticesInRow;
	
	NSBezierPath *backgroundPath = [NSBezierPath bezierPath];
	[backgroundPath moveToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
	for (i=0; i<order; i++) {
		[backgroundPath relativeLineToPoint:NSMakePoint(0.5*unit, -0.5*unit)];
		[backgroundPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
	}
	for (i=0; i<order; i++) {
		[backgroundPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
		[backgroundPath relativeLineToPoint:NSMakePoint(-0.5*unit, 0.5*unit)];
	}
	for (i=0; i<order; i++) {
		[backgroundPath relativeLineToPoint:NSMakePoint(-0.5*unit, 0.5*unit)];
		[backgroundPath relativeLineToPoint:NSMakePoint(-0.5*unit, -0.5*unit)];
	}
	for (i=0; i<order; i++) {
		[backgroundPath relativeLineToPoint:NSMakePoint(-0.5*unit, -0.5*unit)];
		[backgroundPath relativeLineToPoint:NSMakePoint(0.5*unit, -0.5*unit)];
	}
	if (colorful) {
		[[NSColor whiteColor] set];
		[backgroundPath fill];
	}
	
	if (grid) {
		[[NSColor blackColor] set];
		NSBezierPath *gridPath = [NSBezierPath bezierPath];
		
		for (i=0; i<order; i++) {
			[gridPath moveToPoint:NSMakePoint((i+1)*unit,0)];
			[gridPath lineToPoint:NSMakePoint(0,(i+1)*unit)];
			[gridPath moveToPoint:NSMakePoint((i+1)*unit,minSize)];
			[gridPath lineToPoint:NSMakePoint(minSize,(i+1)*unit)];
//			[gridPath moveToPoint:NSMakePoint((2*order+1-i)*unit,0)];
//			[gridPath lineToPoint:NSMakePoint(0,(2*order+1-i)*unit)];
		}
		[gridPath moveToPoint:NSMakePoint((order+0.5)*unit,0.5*unit)];
		[gridPath lineToPoint:NSMakePoint(0.5*unit,(order+0.5)*unit)];

		for (i=0; i<order; i++) {
			[gridPath moveToPoint:NSMakePoint((i+1)*unit,0)];
			[gridPath lineToPoint:NSMakePoint(minSize,minSize-(i+1)*unit)];
			[gridPath moveToPoint:NSMakePoint(0,(i+1)*unit)];
			[gridPath lineToPoint:NSMakePoint(minSize-(i+1)*unit,minSize)];
		}
		[gridPath moveToPoint:NSMakePoint(0.5*unit,0.5*unit)];
		[gridPath lineToPoint:NSMakePoint(minSize-0.5*unit,minSize-0.5*unit)];
		
//		for (i=0;i<order+1; i++) {
//			[gridPath moveToPoint:NSMakePoint(0.5*unit, 0.5*unit + i*unit)];
//			for (j=0; j<order; j++) {
//				[gridPath relativeLineToPoint:NSMakePoint(0.5*unit, -0.5*unit)];
//				[gridPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
//			}
//			[gridPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
//		}
//
//		for (i=0;i<order+1; i++) {
//			[gridPath moveToPoint:NSMakePoint(0.5*unit + i*unit, 0.5*unit)];
//			for (j=0; j<order; j++) {
//				[gridPath relativeLineToPoint:NSMakePoint(-0.5*unit, 0.5*unit)];
//				[gridPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
//			}
//			[gridPath relativeLineToPoint:NSMakePoint(0.5*unit, 0.5*unit)];
//		}
		[gridPath stroke];
		return;
	}
	
	NSBezierPath *allPath = [NSBezierPath bezierPath];
	NSBezierPath *lyingPath = [NSBezierPath bezierPath];
	NSBezierPath *lyingPath2 = [NSBezierPath bezierPath];
	NSBezierPath *standingPath = [NSBezierPath bezierPath];	
	NSBezierPath *standingPath2 = [NSBezierPath bezierPath];	
	NSPoint p;
	for (i=0; i<2*order+1; i++) {
		numVerticesInRow = (i & 1 ? order+1 : order);
		for (j=0; j<numVerticesInRow; j++) {
			v.row = i;
			v.column = j;
			u = [tiling partnerOfVertex:v];
			if (u.row > v.row) {
				if (u.column > v.column - (i&1 ? 1 : 0)) {
					bool shift = !(u.row & 1);
					p.x = (i & 1 ? 0.5*unit : unit) + j*unit;
					p.y = (i & 1 ? 0.5*unit : 0) + i*0.5*unit - (shift ? 0.5*unit : 0);
					[allPath moveToPoint:NSMakePoint(p.x, p.y)];
					[allPath lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 0.5*unit)];
					[allPath lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 1.5*unit)];
					[allPath lineToPoint:NSMakePoint(p.x + unit, p.y + unit)];
					[allPath lineToPoint:NSMakePoint(p.x, p.y)];
					
					if (i & 1) {
						[lyingPath moveToPoint:NSMakePoint(p.x, p.y)];
						[lyingPath lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 0.5*unit)];
						[lyingPath lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 1.5*unit)];
						[lyingPath lineToPoint:NSMakePoint(p.x + unit, p.y + unit)];
						[lyingPath lineToPoint:NSMakePoint(p.x, p.y)];
					}
					else {
						[lyingPath2 moveToPoint:NSMakePoint(p.x, p.y)];
						[lyingPath2 lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 0.5*unit)];
						[lyingPath2 lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 1.5*unit)];
						[lyingPath2 lineToPoint:NSMakePoint(p.x + unit, p.y + unit)];
						[lyingPath2 lineToPoint:NSMakePoint(p.x, p.y)];
					}
				}
				else {
					bool shift = !(u.row & 1); //(v.row/2+v.column > order+1); // || (v.row+v.column > order && v.row<=v.column);
					p.x = (i & 1 ? 0.5*unit : unit) + j*unit; // - (v.row+v.column > order ? 0.5*unit : 0);
					p.y = (i & 1 ? 0.5*unit : 0) + i*0.5*unit - (shift ? 0.5*unit : 0);
					[allPath moveToPoint:NSMakePoint(p.x, p.y)];
					[allPath lineToPoint:NSMakePoint(p.x - unit, p.y + unit)];
					[allPath lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 1.5*unit)];
					[allPath lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 0.5*unit)];
					[allPath lineToPoint:NSMakePoint(p.x, p.y)];

					if (i & 1) {
						[standingPath moveToPoint:NSMakePoint(p.x, p.y)];
						[standingPath lineToPoint:NSMakePoint(p.x - unit, p.y + unit)];
						[standingPath lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 1.5*unit)];
						[standingPath lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 0.5*unit)];
						[standingPath lineToPoint:NSMakePoint(p.x, p.y)];
					}
					else {
						[standingPath2 moveToPoint:NSMakePoint(p.x, p.y)];
						[standingPath2 lineToPoint:NSMakePoint(p.x - unit, p.y + unit)];
						[standingPath2 lineToPoint:NSMakePoint(p.x - 0.5*unit, p.y + 1.5*unit)];
						[standingPath2 lineToPoint:NSMakePoint(p.x + 0.5*unit, p.y + 0.5*unit)];
						[standingPath2 lineToPoint:NSMakePoint(p.x, p.y)];
					}
				}
			}
		}
	}

	if (colorful) {		
		[[NSColor colorWithCalibratedRed:0.2 green:0.7 blue:0 alpha:0.6] set];
		[lyingPath fill];
		[[NSColor colorWithCalibratedRed:0.1 green:0.3 blue:6 alpha:0.6] set];
		[lyingPath2 fill];
		[[NSColor colorWithCalibratedRed:0.7 green:0.1 blue:0 alpha:0.6] set];
		[standingPath fill];
		[[NSColor colorWithCalibratedRed:0.8 green:0.6 blue:0.1 alpha:0.6] set];
		[standingPath2 fill];
	}
	if (order < 40 || (!colorful && order<75))
		[[NSColor blackColor] set];
	else
		[[NSColor colorWithCalibratedWhite:0 alpha:0.3] set];
//	[allPath setLineWidth:1.5];
	[allPath stroke];
	
	if (circle) {
		[[NSColor blueColor] set];
		NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:self.bounds];
		[circlePath setLineWidth:2.0];
		[circlePath stroke];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{	
//	if ([theEvent modifierFlags] & NSControlKeyMask) {
		NSSize dragOffset = NSMakeSize(0.0, 0.0);
		NSPasteboard *pboard;
		NSString *tmpfilepath = @"/tmp/ASM-Simulator.pdf";
		NSArray *fileList = [NSArray arrayWithObject:tmpfilepath];
		PDFDocument *myPDF = [[PDFDocument alloc] initWithData:
							  [self dataWithPDFInsideRect:[self bounds]]];
		[myPDF writeToFile:tmpfilepath];
		[myPDF release];
		NSRect b = self.bounds;
		NSImage *myImage = [[NSImage alloc] initWithData:
							[self dataWithPDFInsideRect:b]];
		pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
		[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType]  owner:nil];
		[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
		NSPoint mousePosition = NSMakePoint(0, 0); // [self convertPoint:[theEvent locationInWindow] fromView:nil];
		[self dragImage:myImage at:mousePosition offset:dragOffset
				  event:theEvent pasteboard:pboard source:self slideBack:YES];		
		return;
//	}
}
	

//- (void)mouseDown:(NSEvent *)theEvent
//{
//	if (!([theEvent modifierFlags] & NSControlKeyMask))
//		self.colorful = !self.colorful;
//}


@end
