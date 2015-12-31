//
//  GameScene.m
//  RailShuffle
//
//  Created by Karl on 2015-12-24.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "GameScene.h"
#import "Cart.h"
#import "ViewController.h"
#import "SoundPlayer.h"

#define SLIDE_TIME 0.16
#define BAR_MAX_SCALE 27.7

#define SIGN_ANIMATION_INTERVAL 0.8

@implementation GameScene

@synthesize myAtlas;
@synthesize backgroundNode;
@synthesize selectionNode;
@synthesize cartTextures;
@synthesize carts;
@synthesize frontHole;
@synthesize counterClockwiseToVerticalCarts;
@synthesize clockwiseToVerticalCarts;
@synthesize counterClockwiseToHorizontalCarts;
@synthesize clockwiseToHorizontalCarts;

@synthesize owner;

static float natureR[3] = {0.8,0.55,0};
static float natureG[3] = {0.6,0.55,0.93};
static float natureB[3] = {0.2,0.55,0};

static float obstacle_adjX[7] = {5,10,14,8,10,7,8};
static float obstacle_adjY[7] = {10,10,1,4,0,5,6};

static float deltaX[5] = {0,0,0,-90.0,90.0};
static float deltaY[5] = {0,60.0,-60.0,0,0};
static int deltaPos[5] = {0,GRIDW,-GRIDW,-1,1};
static int deltaH[5] = {0,0,0,-1,1};
static int deltaV[5] = {0,1,-1,0,0};

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        myAtlas = [SKTextureAtlas atlasNamed:@"pieces"];
        
        backgroundNode = [SKNode node];
        if (size.height > 330) // iPad screen
        {
            isPad = TRUE;
            yScale = 1.0;
            xScale = 1.0;
            gridBaseX = 62.0-180.0;
            gridBaseY = -36.0;
        }
        else
        {
            isPad = FALSE;
            if (size.width > 480) // 4-inch screen
                xScale = 0.48;
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
        flatNames = @[@"flat_orange",@"flat_gray",@"flat_green"];
        obstacleNames = @[@"obst_cactus0",@"obst_cactus1",@"obst_crate0",@"obst_crate1",
                          @"obst_masonry",@"obst_rock0",@"obst_stump0"];
        edgeNames = @[@"edge_orange0",@"edge_gray0",@"edge_green0",
                      @"edge_orange1",@"edge_gray1",@"edge_green1"];
        ornamentNames = @[@" ",@"deco_grass0",@"deco_gravel0",@"deco_gravel1",@"deco_gravel2",
                          @"deco_leaves0",@"deco_leaves1",@"deco_water0",@"deco_water1"];
        self.cartTextures = [NSMutableArray arrayWithCapacity:10];
        for (int i=0;i<10;i++)
            [cartTextures addObject:[myAtlas textureNamed:[NSString stringWithFormat:@"cart%d",i]]];
        self.carts = [NSMutableArray arrayWithCapacity:10];
        counterClockwiseToVerticalCarts = @[[cartTextures objectAtIndex:5],[cartTextures objectAtIndex:4],
                                            [cartTextures objectAtIndex:3],[cartTextures objectAtIndex:2],[cartTextures objectAtIndex:1],[cartTextures objectAtIndex:0]];
        clockwiseToVerticalCarts = @[[cartTextures objectAtIndex:5],[cartTextures objectAtIndex:6],
                                            [cartTextures objectAtIndex:7],[cartTextures objectAtIndex:8],[cartTextures objectAtIndex:9],[cartTextures objectAtIndex:0]];
        counterClockwiseToHorizontalCarts = @[[cartTextures objectAtIndex:0],[cartTextures objectAtIndex:9],
                                            [cartTextures objectAtIndex:8],[cartTextures objectAtIndex:7],[cartTextures objectAtIndex:6],[cartTextures objectAtIndex:5]];
        clockwiseToHorizontalCarts = @[[cartTextures objectAtIndex:0],[cartTextures objectAtIndex:1],
                                     [cartTextures objectAtIndex:2],[cartTextures objectAtIndex:3],[cartTextures objectAtIndex:4],[cartTextures objectAtIndex:5]];
        player = [SoundPlayer sharedSoundPlayer];
        [self prepareSigns];
    }
    return self;
}

-(void)prepareSigns
{
    exitSignHolder = [SKNode node];
    exitSignHolder.zPosition = 100.0;
    SKSpriteNode *tmpS0 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"sign_exit"]];
    tmpS0.anchorPoint = CGPointMake(0,0);
    [exitSignHolder addChild:tmpS0];
    exitCross = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"x"]];
    exitCross.anchorPoint = CGPointMake(0,0);
    exitCross.position = CGPointMake(18.0,22.0);
    [exitSignHolder addChild:exitCross];
    
    levelSignHolder = [SKNode node];
    levelSignHolder.zPosition = 100.0;
    SKSpriteNode *tmpS1 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"sign_level"]];
    tmpS1.anchorPoint = CGPointMake(0,1.0);
    [levelSignHolder addChild:tmpS1];
    digit0 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"0"]];
    digit0.anchorPoint = CGPointMake(0,0);
    digit0.position = CGPointMake(158.0,-76.0);
    [levelSignHolder addChild:digit0];
    digit1 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"0"]];
    digit1.anchorPoint = CGPointMake(0,0);
    digit1.position = CGPointMake(186.0,-76.0);
    [levelSignHolder addChild:digit1];
    
    timerSignHolder = [SKNode node];
    timerSignHolder.zPosition = 100.0;
    SKSpriteNode *tmpS3 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"beige_strip"]];
    tmpS3.anchorPoint = CGPointMake(0,0);
    tmpS3.xScale = BAR_MAX_SCALE;
    tmpS3.yScale = 1.3;
    tmpS3.position = CGPointMake(38.0, -66.0);
    [timerSignHolder addChild:tmpS3];
    timerBar = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"white_strip"]];
    timerBar.anchorPoint = CGPointMake(0,0);
    timerBar.xScale = BAR_MAX_SCALE;
    timerBar.yScale = 1.3;
    timerBar.position = CGPointMake(38.0, -66.0);
    [timerSignHolder addChild:timerBar];
    SKSpriteNode *tmpS2 = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"sign_time"]];
    tmpS2.anchorPoint = CGPointMake(0,1.0);
    [timerSignHolder addChild:tmpS2];
    
    if (isPad)
    {
        exitSignIn = CGPointMake(2,0);
        levelSignIn = CGPointMake(self.size.width-260.0,self.size.height);
        timerSignIn = CGPointMake(10.0,self.size.height);
        
        exitSignOut = CGPointMake(2,-86.0);
        levelSignOut = CGPointMake(self.size.width-260.0,self.size.height+110.0);
        timerSignOut = CGPointMake(10.0,self.size.height+96.0);
        
        exitSignHolder.position = exitSignOut;
        levelSignHolder.position = levelSignOut;
        timerSignHolder.position = timerSignOut;
    }
    else
    {
        exitSignIn = CGPointMake(12.0,0);
        levelSignIn = CGPointMake(6.0,self.size.height);
        timerSignIn = CGPointMake(0,66.0);
        exitSignOut = CGPointMake(12.0,-60.0);
        levelSignOut = CGPointMake(6.0,self.size.height+60.0);
        timerSignOut = CGPointMake(-64.0,66.0);
        
        exitSignHolder.xScale = 0.7;
        exitSignHolder.yScale = 0.7;
        exitSignHolder.position = exitSignOut;

        levelSignHolder.xScale = 0.52;
        levelSignHolder.yScale = 0.52;
        levelSignHolder.position = levelSignOut;
        
        timerSignHolder.zRotation = 1.57;
        timerSignHolder.xScale = 0.64;
        timerSignHolder.yScale = 0.64;
        timerSignHolder.position = timerSignOut;

    }
    [self addChild:exitSignHolder];
    [self addChild:levelSignHolder];
    [self addChild:timerSignHolder];
}

-(void)setupWithLevel:(int)l
{
    level = l;
    [backgroundNode removeAllChildren];
    
    for (int i=0;i<GRIDH;i++)
        for (int j=0;j<GRIDW;j++)
            blockedMap[i][j] = FALSE;
    
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
        SKSpriteNode *bag = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"moneybag"]];
        int xp = [row characterAtIndex:p]-'0'+2;
        int yp = GRIDH-([row characterAtIndex:p+2]-'0')-2;
        
        bag.anchorPoint = CGPointMake(0.45, 0);
        bag.position = CGPointMake(gridBaseX+90.0*xp+45.0, gridBaseY+60.0*yp+5.0);
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
                SKSpriteNode *groundBlock = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[groundNames objectAtIndex:natureType]]];
                groundBlock.anchorPoint = CGPointMake(0, 0);
                groundBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                groundBlock.zPosition = GROUND_Z;
                groundBlock.name = [NSString stringWithFormat:@"ground%d",ix];
                [backgroundNode addChild:groundBlock];
            }
            if (groundMap[i][j] & CONTENT_RAIL)
            {
                SKSpriteNode *railBlock = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[NSString stringWithFormat:@"rails%d",groundMap[i][j]&15]]];
                railBlock.anchorPoint = CGPointMake(0, 0);
                railBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                railBlock.zPosition = RAIL_Z;
                railBlock.name = [NSString stringWithFormat:@"rail%d",ix];
                [backgroundNode addChild:railBlock];
            }
            if (groundMap[i][j] & CONTENT_OBSTACLE)
            {
                SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[obstacleNames objectAtIndex:groundMap[i][j]&15]]];
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
                    holeBlock = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"black"]];
                else if (groundMap[i][j-1] == GROUND_HOLE)
                    holeBlock = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType]]];
                else
                    holeBlock = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:3+natureType]]];
                holeBlock.anchorPoint = CGPointMake(0, 0);
                holeBlock.position = CGPointMake(gridBaseX+90.0*j, gridBaseY+60.0*i);
                holeBlock.zPosition = HOLE_Z;
                holeBlock.name = [NSString stringWithFormat:@"hole%d",ix];
                [backgroundNode addChild:holeBlock];
            }
        }
    // Flat ground cover
    SKSpriteNode *groundCover = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[flatNames objectAtIndex:natureType]]];
    groundCover.anchorPoint = CGPointMake(0, 0);
    groundCover.xScale = GRIDW;
    groundCover.position = CGPointMake(gridBaseX, gridBaseY);
    groundCover.zPosition = GROUND_Z;
    [backgroundNode addChild:groundCover];
    
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
            int xp = 1+(arc4random()%(GRIDW-2));
            int yp = arc4random()%GRIDH;
            if (groundMap[yp][xp] != GROUND_HOLE && (groundMap[yp][xp] & (CONTENT_OBSTACLE | CONTENT_RAIL | 31)) == 0) // Empty
            {
                groundMap[yp][xp] |= j;
                SKSpriteNode *deco = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[ornamentNames objectAtIndex:j]]];
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
    SKSpriteNode *topDeco = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[topNames objectAtIndex:natureType]]];
    topDeco.anchorPoint = CGPointMake(0, 1.0);
    topDeco.xScale = topXScale;
    topDeco.yScale = 1.0;
    topDeco.zPosition = RAIL_Z;
    topDeco.position = CGPointMake(0, screenHeight);
    [backgroundNode addChild:topDeco];
    
    // Highlight
    selectionNode = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"block_highlight"]];
    selectionNode.alpha = 0.5;
    selectionNode.anchorPoint = CGPointMake(0, 0);
    selectionNode.zPosition = SELECTION_Z;
    [backgroundNode addChild:selectionNode];
    [self hideSelection];
    
    // Carts
    p = 0;
    numCarts = 0;
    row = [levRows objectAtIndex:11];
    [carts removeAllObjects];
    while (p < [row length])
    {
        int xp = [row characterAtIndex:p]-'0'+2;
        int yp = GRIDH-([row characterAtIndex:p+2]-'0')-2;
        int dir = [row characterAtIndex:p+4]-'0';
        Cart *newCart = [[Cart alloc] initWithOwner:self xPos:xp yPos:yp andDir:dir];
        newCart.holderNode.position = CGPointMake(gridBaseX+90.0*xp, gridBaseY+60.0*yp);
        p+=6;
        [carts addObject:newCart];
        numCarts++;
    }

    movingPiece = -1;
    self.frontHole = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType]]];
    frontHole.anchorPoint = CGPointMake(0, 0);
    frontHole.zPosition = FRONT_HOLE_Z;
    frontHole.hidden = TRUE;
    [backgroundNode addChild:frontHole];
    
    if (level < 10)
        digit0.texture = NULL;
    else
        digit0.texture = [myAtlas textureNamed:@"1"];
    digit1.texture = [myAtlas textureNamed:[NSString stringWithFormat:@"%d",level%10]];
    
    [self animateSignsIn];
}

-(void)startLevel
{
    gameState = STATE_PLAYING;
    for (Cart *tmpC in carts)
        [tmpC getGoing];
    [player playSong:(level-1)%3];
}

-(void)animateSignsIn
{
    exitSignPressed = FALSE;
    [exitSignHolder runAction:[SKAction moveTo:exitSignIn duration:SIGN_ANIMATION_INTERVAL]];
    [levelSignHolder runAction:[SKAction moveTo:levelSignIn duration:SIGN_ANIMATION_INTERVAL]];
    [timerSignHolder runAction:[SKAction sequence:@[[SKAction moveTo:timerSignIn duration:SIGN_ANIMATION_INTERVAL],
                                                    [SKAction runBlock:^{[self startLevel];}]]]];
}

-(void)animateSignsOut
{
    [player stopSong];
    [exitSignHolder runAction:[SKAction moveTo:exitSignOut duration:SIGN_ANIMATION_INTERVAL]];
    [levelSignHolder runAction:[SKAction moveTo:levelSignOut duration:SIGN_ANIMATION_INTERVAL]];
    [timerSignHolder runAction:[SKAction moveTo:timerSignOut duration:SIGN_ANIMATION_INTERVAL]];
}

-(void)hideSelection
{
    selectionNode.hidden = TRUE;
    selPos = -1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    if (gameState == STATE_PLAYING && movingPiece < 0)
    {
        CGPoint location = [touch locationInNode:backgroundNode];
        int h = (int)((location.x-gridBaseX)/90.0);
        int v = (int)((location.y-gridBaseY)/60.0);
        if (h >= 2 && h < GRIDW-2 && v >= 1 && v < GRIDH-1)
        {
            if ((groundMap[v][h] & GROUND_MOBILE) && ((groundMap[v+1][h]==0 && !blockedMap[v+1][h]) || (groundMap[v-1][h]==0 && !blockedMap[v-1][h]) ||
                                                      (groundMap[v][h+1]==0 && !blockedMap[v][h+1]) || (groundMap[v][h-1]==0 && !blockedMap[v][h-1])))
            {
                selectionNode.position = CGPointMake(gridBaseX+90.0*h, gridBaseY+60.0*v);
                selectionNode.hidden = FALSE;
                selPos = v*GRIDW+h;
                downX = location.x;
                downY = location.y;
            }
            else
                [self hideSelection];
        }
    }
    CGPoint exitLocation = [touch locationInNode:exitCross];
    if (exitLocation.x >= 0 && exitLocation.x < 40.0 && exitLocation.y >= 0 && exitLocation.y < 44.0)
    {
        exitCross.texture = [myAtlas textureNamed:@"x_highlight"];
        exitSignPressed = TRUE;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    if (gameState == STATE_PLAYING)
    {
        CGPoint location = [touch locationInNode:backgroundNode];
        if (selPos >= 0)
        {
            int selH = selPos % GRIDW;
            int selV = selPos / GRIDW;
            // Find best direction
            float dirValues[5];
            for (int i=0;i<5;i++)
                dirValues[i] = -10000.0;
            if (groundMap[selV+1][selH] == GROUND_HOLE)
                dirValues[1] = location.y-downY;
            if (groundMap[selV-1][selH] == GROUND_HOLE)
                dirValues[2] = downY-location.y;
            if (groundMap[selV][selH-1] == GROUND_HOLE)
                dirValues[3] = downX-location.x;
            if (groundMap[selV][selH+1] == GROUND_HOLE)
                dirValues[4] = location.x-downX;
            int bestDir = 0;
            float bestVal = dirValues[0];
            for (int i=1;i<5;i++)
                if (dirValues[i] > bestVal)
                {
                    bestVal = dirValues[i];
                    bestDir = i;
                }
            moveDir = bestDir;
            movingPiece = selPos;
            newPos = movingPiece+deltaPos[moveDir];
            [self hideSelection];
            
            CGVector moveVec = CGVectorMake(deltaX[moveDir], deltaY[moveDir]);
            
            // Create new hole
            SKSpriteNode *newHoleS;
            if (moveDir == 1) // Up
            {
                if (groundMap[selV][selH-1] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType]]];
                else
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]]];
            }
            else if (moveDir == 2) // Down
            {
                if (groundMap[selV+1][selH] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"black"]];
                else if (groundMap[selV][selH-1] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType]]];
                else
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]]];
            }
            else if (moveDir == 3) // Left
            {
                if (groundMap[selV+1][selH] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"black"]];
                else
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]]];
            }
            else if (moveDir == 4) // Right
            {
                if (groundMap[selV+1][selH] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"black"]];
                else if (groundMap[selV][selH-1] == GROUND_HOLE)
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType]]];
                else
                    newHoleS = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]]];
            }
            newHoleS.anchorPoint = CGPointMake(0, 0);
            newHoleS.position = CGPointMake(gridBaseX+90.0*selH, gridBaseY+60.0*selV);
            newHoleS.zPosition = HOLE_Z;
            newHoleS.name = [NSString stringWithFormat:@"hole%d",movingPiece];
            [backgroundNode addChild:newHoleS];
            
            // Possible cleanup in front, if there is already a hole
            if (moveDir != 2 && groundMap[selV-1][selH] == GROUND_HOLE)
            {
                SKSpriteNode *inFrontS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"hole%d",movingPiece-GRIDW]];
                inFrontS.texture = [myAtlas textureNamed:@"black"];
            }
            // Possible cleanup to the right, if there is already a hole
            if (moveDir != 4 && groundMap[selV][selH+1] == GROUND_HOLE && groundMap[selV+1][selH+1] != GROUND_HOLE)
            {
                SKSpriteNode *toRightS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"hole%d",movingPiece+1]];
                toRightS.texture = [myAtlas textureNamed:[edgeNames objectAtIndex:natureType]];
            }
            
            // Duplication of ground value during sliding, to help carts
            groundMap[selV+deltaV[moveDir]][selH+deltaH[moveDir]] = groundMap[selV][selH];
            
            SKSpriteNode *groundS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"ground%d",movingPiece]];
            groundS.name = [NSString stringWithFormat:@"ground%d",newPos];
            
            // Check for rails
            SKSpriteNode *railS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"rail%d",movingPiece]];
            if (railS != NULL)
            {
                railS.name = [NSString stringWithFormat:@"rail%d",newPos];
                [railS runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
            }
            // Check for obstacle
            SKSpriteNode *obstacleS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"obstacle%d",movingPiece]];
            if (obstacleS != NULL)
            {
                obstacleS.name = [NSString stringWithFormat:@"obstacle%d",newPos];
                obstacleS.zPosition = OBSTACLE_Z-(selV+deltaV[moveDir]);
                [obstacleS runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
            }
            // Check for decoration
            SKSpriteNode *decorationS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"decoration%d",movingPiece]];
            if (decorationS != NULL)
            {
                decorationS.name = [NSString stringWithFormat:@"decoration%d",newPos];
                [decorationS runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
            }
            // Check for bag
            SKSpriteNode *bagS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"bag%d",movingPiece]];
            if (bagS != NULL)
            {
                bagS.name = [NSString stringWithFormat:@"bag%d",newPos];
                bagS.zPosition = OBSTACLE_Z-(selV+deltaV[moveDir]);
                [bagS runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
            }
            
            // Front hole
            frontHole.position = CGPointMake(gridBaseX+90.0*selH, gridBaseY+60.0*(selV-1));
            frontHole.hidden = FALSE;
          
            [groundS runAction:[SKAction sequence:@[[SKAction moveBy:moveVec duration:SLIDE_TIME],[SKAction runBlock:^{[self finishedSliding];}]]]];
            [frontHole runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
            
            for (Cart *tmpC in carts)
            {
                if (tmpC.xp == selH && tmpC.yp == selV)
                {
                    tmpC.xp+=deltaH[moveDir];
                    tmpC.yp+=deltaV[moveDir];
                    [tmpC.holderNode runAction:[SKAction moveBy:moveVec duration:SLIDE_TIME]];
                }
            }
            
            [player playSlide];
        }
    }
    if (exitSignPressed)
    {
        exitCross.texture = [myAtlas textureNamed:@"x"];
        exitSignPressed = FALSE;
        [[SoundPlayer sharedSoundPlayer] playClick];
        [self exitPressed];
    }

}

-(void)finishedSliding
{
    int originH = movingPiece % GRIDW;
    int originV = movingPiece / GRIDW;
    groundMap[originV][originH] = GROUND_HOLE;
    SKSpriteNode *holeS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"hole%d",newPos]];
    if (holeS != NULL)
        [holeS removeFromParent];
    // Possible cleanup in front
    if (moveDir != 1 && groundMap[(newPos/GRIDW)-1][newPos%GRIDW] == GROUND_HOLE)
    {
        SKSpriteNode *inFrontS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"hole%d",newPos-GRIDW]];
        if (groundMap[(newPos/GRIDW)-1][(newPos%GRIDW)-1] == GROUND_HOLE)
            inFrontS.texture = [myAtlas textureNamed:[edgeNames objectAtIndex:natureType]];
        else
            inFrontS.texture = [myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]];
    }
    // Possible cleanup to the right
    if (moveDir != 3 && groundMap[(newPos/GRIDW)][(newPos%GRIDW)+1] == GROUND_HOLE && groundMap[(newPos/GRIDW)+1][(newPos%GRIDW)+1] != GROUND_HOLE)
    {
        SKSpriteNode *toRightS = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"hole%d",newPos+1]];
        toRightS.texture = [myAtlas textureNamed:[edgeNames objectAtIndex:natureType+3]];
    }
    frontHole.hidden = TRUE;
    movingPiece = -1;
}

-(int)getGroundAtH:(int)h andV:(int)v
{
    return groundMap[v][h];
}

-(void)checkForBagAt:(int)pos withCartZ:(float)z
{
    SKSpriteNode *bag = (SKSpriteNode*)[backgroundNode childNodeWithName:[NSString stringWithFormat:@"bag%d",pos]];
    if (bag != NULL)
    {
        numBags--;
        bag.zPosition = z+0.5;
        bag.texture = [myAtlas textureNamed:@"jump_bag"];
        SKAction *moveUp = [SKAction moveByX:0 y:100 duration:0.3];
        moveUp.timingMode = SKActionTimingEaseOut;
        SKAction *moveDown = [SKAction moveByX:0 y:-60 duration:0.2];
        moveDown.timingMode = SKActionTimingEaseIn;
        
        SKSpriteNode *shadow = [SKSpriteNode spriteNodeWithTexture:[myAtlas textureNamed:@"money_shadow"]];
        shadow.anchorPoint = CGPointMake(0.4, 0);
        shadow.zPosition = SHADOW_Z;
        shadow.position = bag.position;
        [backgroundNode addChild:shadow];
        
        SKAction *shadowAway = [SKAction moveByX:80 y:-40 duration:0.3];
        shadowAway.timingMode = SKActionTimingEaseOut;
        SKAction *shadowBack = [SKAction moveByX:-60 y:30 duration:0.2];
        shadowBack.timingMode = SKActionTimingEaseIn;
        
        SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"starburst" ofType:@"sks"]];
        stars.position = CGPointMake(bag.position.x,bag.position.y+30.0);
        stars.zPosition = z-0.1;
        [backgroundNode addChild:stars];
        
        [bag runAction:[SKAction group:@[[SKAction scaleBy:0.5 duration:0.8],[SKAction fadeAlphaTo:0 duration:0.8],[SKAction sequence:@[moveUp,moveDown,[SKAction runBlock:^{[self checkForSolved];}],[SKAction removeFromParent]]]]]];
        [shadow runAction:[SKAction group:@[[SKAction scaleBy:0.5 duration:0.8],[SKAction fadeAlphaTo:0 duration:0.8],[SKAction sequence:@[shadowAway,shadowBack,[SKAction removeFromParent]]]]]];
        [player playChime];
    }
}

-(void)setBlocked:(BOOL)b atH:(int)h andV:(int)v
{
    blockedMap[v][h] = b;
}

-(void)checkForSolved
{
    if (numBags == 0) // All done
    {
        gameState = STATE_SOLVED;
        for (Cart *tmpC in carts)
            [tmpC haltMotion];
        
        [self animateSignsOut];
    }
}

-(void)checkForFailed
{
    if (numCarts <= 0 && gameState == STATE_PLAYING)
    {
        gameState = STATE_FAIL;
        
        [self animateSignsOut];
    }
}

-(void)exitPressed
{
    [player playClick];
    [self animateSignsOut];
    for (Cart *tmpC in carts)
        [tmpC haltMotion];
    [owner fadeOutGameScene];
}

-(void)cartStopped
{
    numCarts--;
    [self performSelector:@selector(checkForFailed) withObject:NULL afterDelay:1.0];
}

-(void)cartCrashed:(Cart*)c
{
    numCarts--;
    [c haltMotion];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"smoke" ofType:@"sks"]];
    smoke.position = CGPointMake(c.holderNode.position.x+c.sprite.position.x,c.holderNode.position.y+c.sprite.position.y);
    smoke.zPosition = c.holderNode.zPosition+0.1;
    [backgroundNode addChild:smoke];
    SKEmitterNode *flames = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"flames" ofType:@"sks"]];
    flames.position = smoke.position;
    flames.zPosition = smoke.zPosition+0.1;
    [backgroundNode addChild:flames];
    SKEmitterNode *shards = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"shards" ofType:@"sks"]];
    shards.position = smoke.position;
    shards.zPosition = smoke.zPosition+0.2;
    [backgroundNode addChild:shards];
    [c.holderNode removeFromParent];
    [[SoundPlayer sharedSoundPlayer] playCrash];
    
    [self performSelector:@selector(checkForFailed) withObject:NULL afterDelay:1.0];
}

@end
