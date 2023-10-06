//
//  AztecTiling.m
//  ASM-Sim
//
//  Created by Dan Romik on 6/26/09.
//  Copyright 2009 Dan Romik. All rights reserved.
//

#import "AztecTiling.h"
#import "ASM.h"

@implementation AztecTiling
@synthesize order;


- (AztecTiling *)initTrivialTilingWithOrder:(int)ord
{
	if (self = [super init]) {
		order = ord;
		data = [[NSMutableData alloc] initWithLength:(2*order+1)*(order+1)*sizeof(AztecGraphVertex)];
//		int i,j;
		AztecGraphVertex v, u;
//		u.row = -10;
//		u.column = -10;
//		for (v.row=0; v.row<2*order+1; v.row++)
//			for (v.column=0; v.column<order+1; v.column++) {
//				((AztecGraphVertex *)[data mutableBytes])[v.row * (order+1) + v.column] = u;
//			}
//		for (j=0; j<order; j++) {
//			v.row = 0;
//			v.column = j;
//			u.row = 1;
//			u.column = j+1;
//			[self partnerVertex:v with:u];
//		}
//		for (i=1; i<2*order+1; i++) {
//			int numVerticesInRow = (i & 1 ? order+1 : order);
//			for (j=0; j<numVerticesInRow; j++) {
//				v.row = i;
//				v.column = j;
//				if (![self hasPartnerFor:v]) {
//					u.row = i+1;
//					u.column = j+(i&1 ? 0 : 1);
//					[self partnerVertex:v with:u];
//				}
//			}
//		}
		
		int i,k;
		for (k=0; k<order; k++) {
			for (i=0; i<k+1; i++) {
				v.row = 2*k+1 - 2*i;
				v.column = i;
				u.row = v.row - 1;
				u.column = v.column;
				[self partnerVertex:v with:u];

				v.row = 2*order - 2*i;
				v.column = order-1-k + i;
				u.row = v.row - 1;
				u.column = v.column+1;
//				NSLog(@"(%d,%d) --- (%d,%d)",v.row,v.column,u.row,u.column);
				[self partnerVertex:v with:u];
			}
		}
		
	}
	return self;
}

- (AztecTiling *)initWithBigASM:(ASM *)bigASM smallASM:(ASM *)smallASM
{
	order = bigASM.order;
	if (self = [self initTrivialTilingWithOrder:order]) {
		Matrix *iceMatrix = [bigASM squareIceMatrix];
		int i,j;
		AztecGraphVertex u, v;
		for (i = 0; i<order; i++)
			for (j = 0; j<order; j++) {
				switch ((IceMolecule)[iceMatrix entryInRow:i column:j]) {
					case IceMoleculeNorthEast:
						v.row = 2*i;
						v.column = j;
						u.row = 2*i+1;
						u.column = j;
						[self partnerVertex:v with:u];
						break;
					case IceMoleculeNorthWest:
						v.row = 2*i;
						v.column = j;
						u.row = 2*i+1;
						u.column = j+1;
						[self partnerVertex:v with:u];
						break;
					case IceMoleculeSouthEast:
						v.row = 2*i+2;
						v.column = j;
						u.row = 2*i+1;
						u.column = j;
						[self partnerVertex:v with:u];
						break;
					case IceMoleculeSouthWest:
						v.row = 2*i+2;
						v.column = j;
						u.row = 2*i+1;
						u.column = j+1;
						[self partnerVertex:v with:u];
						break;
					case IceMoleculeHorizontal:
						if ((bool)(random()&1)) {			// fix this to take the small ASM into account
							v.row = 2*i;
							v.column = j;
							u.row = 2*i+1;
							u.column = j;
							[self partnerVertex:v with:u];
							v.row = 2*i+2;
							v.column = j;
							u.row = 2*i+1;
							u.column = j+1;
							[self partnerVertex:v with:u];
						}
						else {
							v.row = 2*i;
							v.column = j;
							u.row = 2*i+1;
							u.column = j+1;
							[self partnerVertex:v with:u];
							v.row = 2*i+2;
							v.column = j;
							u.row = 2*i+1;
							u.column = j;
							[self partnerVertex:v with:u];
						}
						break;
					case IceMoleculeVertical:
						break;
				}
			}
	}
	return self;
}

- (bool)hasPartnerFor:(AztecGraphVertex)vertex
{
	AztecGraphVertex v = [self partnerOfVertex:vertex];
	if (v.row - vertex.row != -1 && v.row - vertex.row != 1)
		return NO;
	if (v.row & 1)
		return (v.column == vertex.column || v.column == vertex.column + 1);
	return (v.column == vertex.column || v.column == vertex.column - 1);
}

- (AztecGraphVertex)partnerOfVertex:(AztecGraphVertex)vertex
{
	return ((AztecGraphVertex *)[data bytes])[vertex.row * (order+1) + vertex.column];
}

- (void)partnerVertex:(AztecGraphVertex)vertex with:(AztecGraphVertex)partnerVertex
{
	((AztecGraphVertex *)[data mutableBytes])[vertex.row * (order+1) + vertex.column] = partnerVertex;
	((AztecGraphVertex *)[data mutableBytes])[partnerVertex.row * (order+1) + partnerVertex.column] = vertex;
}

- (NSString *)description
{
	NSMutableString *str = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
	int i,j;
	[str appendFormat:@"AztecTiling of order %d = \{\n", order];
	AztecGraphVertex v, u;
	for (i=0; i<2*order+1; i++) {
		int numVerticesInRow = (i & 1 ? order+1 : order);
		v.row = i;
		for (j=0; j<numVerticesInRow; j++) {
			v.column = j;
			if ([self hasPartnerFor:v]) {
				u = [self partnerOfVertex:v];
				if (u.row > v.row)
					[str appendFormat:@"  (%d,%d) <-> (%d,%d)\n",v.row,v.column,u.row,u.column];
			}
			else {
				NSLog(@"Error: vertex (%d,%d) has no partner! (%d,%d)", v.row, v.column, u.row, u.column);
			}
		}
	}
	return str;
}

- (void)dealloc
{
	[data release];
	[super dealloc];
}



@end
