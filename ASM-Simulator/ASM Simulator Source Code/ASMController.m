//
//  ASMController.m
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import "ASMController.h"

#import "ASM.h"
#import "AztecTiling.h"

@implementation ASMController

- (ASM *)myASM
{
	return theASMView.myASM;
}

- (void)setMyASM:(ASM *)newASM
{
	theASMView.myASM = newASM;
	secondaryASMView.myASM = newASM;
	AztecTiling *tiling = [[[AztecTiling alloc] initWithBigASM:newASM smallASM:nil] autorelease];
	tilingView.tiling = tiling;
//	NSLog(@"%@",[tiling description]);
}

- (void)awakeFromNib
{
//	[self reset:self];
#define INITIAL_ORDER		6
	self.myASM = [ASM randomDominoASMOfOrder:INITIAL_ORDER];
	orderLabel.intValue = INITIAL_ORDER;
	
//	AztecTiling *tiling = [[AztecTiling alloc] initTrivialTilingWithOrder:10];
//	tilingView.tiling = tiling;
//	NSLog(@"%@",[tiling description]);
}

- (void)reset:(id)sender
{
	self.myASM = [[[ASM alloc] initIdentityWithOrder:1] autorelease];
	orderLabel.intValue = 1;
}

- (void)toggleGrid:(id)sender
{
	theASMView.gridOn = !theASMView.gridOn;
}

- (void)toggleToggle:(id)sender
{
	theASMView.toggleOn = !theASMView.toggleOn;
}

- (void)step
{
	self.myASM = [theASMView.myASM randomGrowthASM];
}

- (void)step1:(id)sender
{
	[self step];
	orderLabel.intValue = orderLabel.intValue + 1;
}

- (void)step10:(id)sender
{
	int i;
	for (i=0; i<10; i++)
		[self step];
	orderLabel.intValue = orderLabel.intValue + 10;
}

- (void)step100:(id)sender
{
	int i;
	for (i=0; i<100; i++)
		[self step];
	orderLabel.intValue = orderLabel.intValue + 100;
}	

- (void)animateStop:(NSButton *)sender
{
	if (animationTimer) {
		[animationTimer invalidate];
		[animationTimer release];
		animationTimer = nil;
		[sender setTitle:@"Animate"];
	}
	else {
		animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES] retain];
		[sender setTitle:@"Stop"];
	}
}

- (void)timerAction:(NSTimer *)timer
{
	[self step1:nil];
}

- (void)toggleCircle:(id)sender
{
	theASMView.circleOn = !theASMView.circleOn;
}

- (IBAction)toggleColomoPronko:(id)sender
{
	theASMView.CPLimitShapeOn = !theASMView.CPLimitShapeOn;
}

- (void)toggleHighlightDownArrows:(id)sender
{
	theASMView.highlightDownArrows = !theASMView.highlightDownArrows;
}

- (void)openAboutWindow:(id)sender
{
	NSString *aboutFilename = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"];
	[[NSWorkspace sharedWorkspace] openFile:aboutFilename];
}

- (void)dealloc
{
	if (animationTimer) {
		[animationTimer invalidate];
		[animationTimer release];
	}
	[super dealloc];
}

@end
