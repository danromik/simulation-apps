//
//  ASMController.h
//  asm
//
//  Created by Dan Romik on 6/8/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ASMView.h"
#import "AztecTilingView.h"

@interface ASMController : NSObject {
	IBOutlet ASMView *theASMView;
	IBOutlet ASMView *secondaryASMView;
	IBOutlet NSTextField *orderLabel;
	IBOutlet AztecTilingView *tilingView;
	
	NSTimer *animationTimer;
}
@property (readwrite, retain) ASM *myASM;

- (IBAction)reset:(id)sender;
- (IBAction)step1:(id)sender;
- (IBAction)step10:(id)sender;
- (IBAction)step100:(id)sender;
- (IBAction)toggleCircle:(id)sender;
- (IBAction)toggleHighlightDownArrows:(id)sender;
- (IBAction)toggleGrid:(id)sender;
- (IBAction)toggleColomoPronko:(id)sender;
- (void)toggleToggle:(id)sender;

- (IBAction)animateStop:(NSButton *)sender;
- (void)timerAction:(NSTimer *)timer;

- (IBAction)openAboutWindow:(id)sender;

@end
