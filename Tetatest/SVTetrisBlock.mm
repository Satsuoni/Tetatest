//
//  SVTetrisBlock.m
//  Tetatest
//
//  Created by Seva Yugov on 10/1/11.
//  Copyright 2011 Tokodai. All rights reserved.
//

#import "SVTetrisBlock.h"
#import "SVTetrisBody.h"

@implementation SVTetrisBlock
@synthesize isinGrid;
@synthesize isinFigure;
@synthesize freeFall;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
