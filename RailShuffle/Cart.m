//
//  Cart.m
//  RailShuffle
//
//  Created by Karl on 2015-12-26.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "Cart.h"
#import "GameScene.h"

#define BLOCK_INTERVAL 0.5

@implementation Cart

@synthesize holderNode;

static int deltaH[5] = {0,0,0,-1,1};
static int deltaV[5] = {0,1,-1,0,0};
static float deltaX[5] = {0,0,0,-90.0,90.0};
static float deltaY[5] = {0,60.0,-60.0,0,0};

-(id)initWithOwner:(GameScene*)o xPos:(int)x yPos:(int)y andDir:(int)d
{
    if (self = [super init]) {
        owner = o;
        xp = x;
        yp = y;
        lastPos = y*GRIDW+x;
        dir = d;
        if (dir == 1 || dir == 2) // Vertical
            sprite = [SKSpriteNode spriteNodeWithTexture:[owner.cartTextures objectAtIndex:0]];
        else
            sprite = [SKSpriteNode spriteNodeWithTexture:[owner.cartTextures objectAtIndex:5]];
        sprite.position = CGPointMake(45.0, 30.0);
        sprite.anchorPoint = CGPointMake(0.455, 0.34);
        self.holderNode = [SKNode node];
        holderNode.zPosition =  OBSTACLE_Z-yp;
        [holderNode addChild:sprite];
        [owner.backgroundNode addChild:holderNode];
    }
    return self;
}

-(void)getGoing
{
    [sprite runAction:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(deltaX[dir]*0.5, deltaY[dir]*0.5) duration:BLOCK_INTERVAL*0.5],[SKAction runBlock:^{[self takeNextStep];}]]]];
}

-(void)takeNextStep
{
    int nextGround = [owner getGroundAtH:xp+deltaH[dir] andV:yp+deltaV[dir]];
    if (nextGround & CONTENT_OBSTACLE) // Crash
    {
        
    }
    else if (nextGround & GROUND_FIXED) // Halt
    {
        
    }
    else if (nextGround == GROUND_HOLE) // Hole
    {
        
    }
    else
    {
        int railType = nextGround & 15;
        if (dir == 1) // Up
        {
            if (railType == 1 || railType == 2 || railType == 11 || railType == 12 ||
                railType == 13 || railType == 14) // Keep going
            {
                [self goStraight];
            }
            else if (railType == 4 || railType == 8) // Turn left
            {
                
            }
            else if (railType == 3 || railType == 7) // Turn right
            {
                
            }
            else // Halt
            {
                
            }
        }
        else if (dir == 2) // Down
        {
            if (railType == 1 || railType == 2 || railType == 11 || railType == 12 ||
                railType == 13 || railType == 14) // Keep going
            {
                [self goStraight];
            }
            else if (railType == 6 || railType == 10) // Turn left
            {
                
            }
            else if (railType == 5 || railType == 9) // Turn right
            {
                
            }
            else // Halt
            {
                
            }
       }
        else if (dir == 3) // Left
        {
            if (railType == 0 || railType == 2 || railType == 7 || railType == 8 ||
                railType == 9 || railType == 10) // Keep going
            {
                [self goStraight];
            }
            else if (railType == 5 || railType == 13) // Turn up
            {
                
            }
            else if (railType == 3 || railType == 11) // Turn down
            {
                
            }
            else // Halt
            {
                
            }
        }
        else if (dir == 4) // Right
        {
            if (railType == 0 || railType == 2 || railType == 7 || railType == 8 ||
                railType == 9 || railType == 10) // Keep going
            {
                [self goStraight];
            }
            else if (railType == 6 || railType == 14) // Turn up
            {
                
            }
            else if (railType == 4 || railType == 12) // Turn down
            {
                
            }
            else // Halt
            {
                
            }
        }
    }
}

-(void)goStraight
{
    newDir = dir;
    [sprite runAction:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(deltaX[dir], deltaY[dir]) duration:BLOCK_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]]];
}

-(void)stepFinished
{
    holderNode.position = CGPointMake(holderNode.position.x+deltaX[dir], holderNode.position.y+deltaY[dir]);
    sprite.position = CGPointMake(sprite.position.x-deltaX[dir], sprite.position.y-deltaY[dir]);
    xp += deltaH[dir];
    yp += deltaV[dir];
    dir = newDir;
    [self takeNextStep];
}

@end
