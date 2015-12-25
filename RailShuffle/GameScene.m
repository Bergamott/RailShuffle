//
//  GameScene.m
//  RailShuffle
//
//  Created by Karl on 2015-12-24.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

@synthesize myAtlas;
@synthesize backgroundNode;

static int levelNature[16] = {0,1,1,0,1,2,0,2,2,1,2,0,0,2,0,1};
static float natureR[3] = {0.8,0.55,0};
static float natureG[3] = {0.6,0.55,0.93};
static float natureB[3] = {0.2,0.55,0};

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        myAtlas = [SKTextureAtlas atlasNamed:@"pieces"];
        
        backgroundNode = [SKNode node];
        if (size.height > 330) // iPad screen
        {
            yScale = 1.0;
            xScale = 1.0;
            gridBaseX = 62.0-180.0;
            gridBaseY = -30.0;
        }
        else
        {
            if (size.width > 480) // 4-inch screen
                xScale = 0.49;
            else // 3.5-inch screen
                xScale = 0.412;
            yScale = 0.412;
            gridBaseX = 0;
            gridBaseY = -36.0;
        }
        screenHeight = size.height / yScale;
        topXScale = (size.width/1024.0)/xScale;
        [backgroundNode setXScale:xScale];
        [backgroundNode setYScale:yScale];
        
        [self addChild:backgroundNode];
        
        topNames = @[@"top_desert",@"top_rocks",@"top_vegetation"];
        groundNames = @[@"block_orange",@"block_gray",@"block_green"];
    }
    return self;
}

-(void)setupWithLevel:(int)l
{
    level = l;
    [backgroundNode removeAllChildren];
    self.backgroundColor = [SKColor colorWithRed:natureR[levelNature[l]] green:natureG[levelNature[l]] blue:natureB[levelNature[l]] alpha:1];
    
    for (int i=0;i<12;i++)
        for (int j=0;j<14;j++)
        {
            if (j>=2 && j<12 && i>= 1 && i < 11)
            {
                SKSpriteNode *groundBlock = [SKSpriteNode spriteNodeWithImageNamed:[groundNames objectAtIndex:levelNature[level]]];
                groundBlock.anchorPoint = CGPointMake(0, 0);
                groundBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                [backgroundNode addChild:groundBlock];
            }
        }
    
    // Set top decoration
    SKSpriteNode *topDeco = [SKSpriteNode spriteNodeWithImageNamed:[topNames objectAtIndex:levelNature[level]]];
    topDeco.anchorPoint = CGPointMake(0, 1.0);
    topDeco.xScale = topXScale;
    topDeco.yScale = 1.0;
    topDeco.position = CGPointMake(0, screenHeight);
    [backgroundNode addChild:topDeco];
}

@end
