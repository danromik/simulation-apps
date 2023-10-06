//
//  AztecTilingView.h
//  ASM-Sim
//
//  Created by Dan Romik on 6/27/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AztecTiling;

@interface AztecTilingView : NSView {
	AztecTiling *tiling;
	bool circle;
	bool colorful;
	bool rotated;
	bool grid;
}
@property (readwrite, retain) AztecTiling *tiling;
@property (readwrite) bool circle;
@property (readwrite) bool colorful;
@property (readwrite) bool rotated;
@property (readwrite) bool grid;

- (IBAction)takeCircleFrom:(NSButton *)checkbox;
- (IBAction)takeRotatedFrom:(NSButton *)checkbox;
- (IBAction)takeColorfulFrom:(NSButton *)checkbox;
- (IBAction)takeGridFrom:(NSButton *)checkbox;

@end
