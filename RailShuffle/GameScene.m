//
//  GameScene.m
//  RailShuffle
//
//  Created by Karl on 2015-12-24.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "GameScene.h"

#define GROUND_HOLE 0
#define GROUND_FIXED 32
#define GROUND_MOBILE 64
#define GROUND_SELECTED 96

#define CONTENT_RAIL 128
#define CONTENT_OBSTACLE 256

#define HOLE_Z -2.0
#define GROUND_Z 0
#define SELECTION_Z 1.0
#define DECORATION_Z 2.0
#define RAIL_Z 3.0
#define OBSTACLE_Z 50.0

@implementation GameScene

@synthesize myAtlas;
@synthesize backgroundNode;
@synthesize selectionNode;

static float natureR[3] = {0.8,0.55,0};
static float natureG[3] = {0.6,0.55,0.93};
static float natureB[3] = {0.2,0.55,0};

static float obstacle_adjX[7] = {5,10,14,8,10,7,8};
static float obstacle_adjY[7] = {10,10,1,4,0,5,6};

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
            gridBaseY = -36.0;
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
        obstacleNames = @[@"obst_cactus0",@"obst_cactus1",@"obst_crate0",@"obst_crate1",
                          @"obst_masonry",@"obst_rock0",@"obst_stump0"];
        edgeNames = @[@"edge_orange0",@"edge_gray0",@"edge_green0",
                      @"edge_orange1",@"edge_gray1",@"edge_green1"];
        ornamentNames = @[@" ",@"deco_grass0",@"deco_gravel0",@"deco_gravel1",@"deco_gravel2",
                          @"deco_leaves0",@"deco_leaves1",@"deco_water0",@"deco_water1"];
    }
    return self;
}

-(void)setupWithLevel:(int)l
{
    level = l;
    [backgroundNode removeAllChildren];
    
    // Load data from file
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d",level] ofType:@"txt"];
    NSError *err = nil;
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    NSArray *levRows = [string componentsSeparatedByString:@"\n"];
    for (int i=0;i<GRIDH;i++)
        for (int j=0;j<GRIDW;j++)
            groundMap[i][j] = GROUND_FIXED;
    NSString *row;
    for (NSUInteger i=0;i<GRIDH-2;i++)
    {
        row = (NSString *)[levRows objectAtIndex:i];
        for (NSUInteger j=0;j<GRIDW-4;j++)
        {
            unichar c=[row characterAtIndex:j];
            int k = GROUND_FIXED;
            if (c==' ')
                k = GROUND_HOLE;
            else if (c=='.')
                k = GROUND_MOBILE;
            else if (c >= 'a' && c <= 'o')
                k = GROUND_MOBILE + CONTENT_RAIL + c - 'a';
            groundMap[GRIDH-2-i][j+2] = k;
        }
    }
    
    // Money bags
    numBags = 0;
    row = [levRows objectAtIndex:12];
    int p = 0;
    while (p < [row length])
    {
        SKSpriteNode *bag = [SKSpriteNode spriteNodeWithImageNamed:@"moneybag"];
        int xp = [row characterAtIndex:p]-'0'+2;
        int yp = GRIDH-([row characterAtIndex:p+2]-'0')-2;
        
        bag.anchorPoint = CGPointMake(0, 0);
        bag.position = CGPointMake(gridBaseX+90.0*xp+14.0, gridBaseY+60.0*yp+5.0);
        bag.zPosition = OBSTACLE_Z-yp;
        bag.name = [NSString stringWithFormat:@"bag%d",GRIDW*yp+xp];
        [backgroundNode addChild:bag];
        p+=4;
        numBags++;
    }
    
    // Obstacles
    row = [levRows objectAtIndex:13];
    p = 0;
    while (p < [row length])
    {
        int xp = [row characterAtIndex:p]-'0'+2;
        int yp = GRIDH-([row characterAtIndex:p+2]-'0')-2;
        int oLook = [row characterAtIndex:p+4]-'0';
        groundMap[yp][xp] |= (CONTENT_OBSTACLE | oLook);
        p+=6;
    }
    
    // Ground type to use
    row =  [levRows objectAtIndex:10];
    natureType = [row characterAtIndex:0]-'0';
    
    self.backgroundColor = [SKColor colorWithRed:natureR[natureType] green:natureG[natureType] blue:natureB[natureType] alpha:1];
    
    for (int i=0;i<GRIDH;i++)
        for (int j=0;j<GRIDW;j++)
        {
            int ix = i*GRIDW+j;
            if (groundMap[i][j] & GROUND_MOBILE)
            {
                SKSpriteNode *groundBlock = [SKSpriteNode spriteNodeWithImageNamed:[groundNames objectAtIndex:natureType]];
                groundBlock.anchorPoint = CGPointMake(0, 0);
                groundBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                groundBlock.zPosition = GROUND_Z;
                groundBlock.name = [NSString stringWithFormat:@"ground%d",ix];
                [backgroundNode addChild:groundBlock];
            }
            if (groundMap[i][j] & CONTENT_RAIL)
            {
                SKSpriteNode *railBlock = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"rails%d",groundMap[i][j]&15]];
                railBlock.anchorPoint = CGPointMake(0, 0);
                railBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                railBlock.zPosition = RAIL_Z;
                railBlock.name = [NSString stringWithFormat:@"rail%d",ix];
                [backgroundNode addChild:railBlock];
            }
            if (groundMap[i][j] & CONTENT_OBSTACLE)
            {
                SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:[obstacleNames objectAtIndex:groundMap[i][j]&15]];
                obstacle.anchorPoint = CGPointMake(0, 0);
                obstacle.position = CGPointMake(gridBaseX+90.0*j+obstacle_adjX[groundMap[i][j]&15], gridBaseY+60.0*i+obstacle_adjY[groundMap[i][j]&15]);
                obstacle.zPosition = OBSTACLE_Z-i;
                obstacle.name = [NSString stringWithFormat:@"obstacle%d",ix];
                [backgroundNode addChild:obstacle];
            }
            if (groundMap[i][j] == GROUND_HOLE)
            {
                SKSpriteNode *holeBlock;
                if (groundMap[i+1][j] == GROUND_HOLE)
                    holeBlock = [SKSpriteNode spriteNodeWithImageNamed:@"black"];
                else if (groundMap[i][j-1] == GROUND_HOLE)
                    holeBlock = [SKSpriteNode spriteNodeWithImageNamed:[edgeNames objectAtIndex:natureType]];
                else
                    holeBlock = [SKSpriteNode spriteNodeWithImageNamed:[edgeNames objectAtIndex:3+natureType]];
                holeBlock.anchorPoint = CGPointMake(0, 0);
                holeBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                holeBlock.zPosition = GROUND_Z;
                holeBlock.name = [NSString stringWithFormat:@"hole%d",ix];
                [backgroundNode addChild:holeBlock];
            }
        }
    
    // Ground ornaments
    row = [levRows objectAtIndex:14];
    p = 0;
    while (p < [row length])
    {
        int j = [row characterAtIndex:p]-'0'; // Type of ornament
        int k = [row characterAtIndex:p+2]-'0'; // Number of occurrences
        int n = 0;
        while (n < k)
        {
            int xp = arc4random()%GRIDW;
            int yp = arc4random()%GRIDH;
            if (groundMap[yp][xp] != GROUND_HOLE && (groundMap[yp][xp] & (CONTENT_OBSTACLE | CONTENT_RAIL | 31)) == 0) // Empty
            {
                groundMap[yp][xp] |= j;
                SKSpriteNode *deco = [SKSpriteNode spriteNodeWithImageNamed:[ornamentNames objectAtIndex:j]];
                deco.anchorPoint = CGPointMake(0, 0);
                deco.position = CGPointMake(gridBaseX+90.0*xp, gridBaseY+60.0*yp);
                deco.zPosition = DECORATION_Z;
                deco.name = [NSString stringWithFormat:@"decoration%d",yp*GRIDW+xp];
                [backgroundNode addChild:deco];
                n++;
            }
        }
        p+=4;
    }
    
    // Set top decoration
    SKSpriteNode *topDeco = [SKSpriteNode spriteNodeWithImageNamed:[topNames objectAtIndex:natureType]];
    topDeco.anchorPoint = CGPointMake(0, 1.0);
    topDeco.xScale = topXScale;
    topDeco.yScale = 1.0;
    topDeco.zPosition = RAIL_Z;
    topDeco.position = CGPointMake(0, screenHeight);
    [backgroundNode addChild:topDeco];
    
    // Highlight
    selectionNode = [SKSpriteNode spriteNodeWithImageNamed:@"block_highlight"];
    selectionNode.alpha = 0.5;
    selectionNode.anchorPoint = CGPointMake(0, 0);
    selectionNode.zPosition = SELECTION_Z;
    [backgroundNode addChild:selectionNode];
    [self hideSelection];
    
    
}

-(void)hideSelection
{
    selectionNode.hidden = TRUE;
    selPos = -1;
}


@end
