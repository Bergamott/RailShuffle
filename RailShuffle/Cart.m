//
//  Cart.m
//  RailShuffle
//
//  Created by Karl on 2015-12-26.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "Cart.h"
#import "GameScene.h"

#define BLOCK_INTERVAL 0.8
#define CURVE_INTERVAL 0.64
#define FALL_INTERVAL 1.0

@implementation Cart

@synthesize holderNode;
@synthesize sprite;
@synthesize xp;
@synthesize yp;

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
    holderNode.zPosition = OBSTACLE_Z-yp-deltaV[dir];
    [owner checkForBagAt:(yp+deltaV[dir])*GRIDW+xp+deltaH[dir] withCartZ:holderNode.zPosition];
    if (nextGround & CONTENT_OBSTACLE) // Crash
    {
        [self crash];
    }
    else if (nextGround == GROUND_HOLE) // Hole
    {
        [self goIntoHole];
    }
    else if (nextGround & CONTENT_RAIL) // Rails
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
                [self goCounterClockwiseLeft];
            }
            else if (railType == 3 || railType == 7) // Turn right
            {
                [self goClockwiseRight];
            }
            else // Halt
            {
                [self comeToAHalt];
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
                [self goClockwiseLeft];
            }
            else if (railType == 5 || railType == 9) // Turn right
            {
                [self goCounterClockwiseRight];
            }
            else // Halt
            {
                [self comeToAHalt];
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
                [self goClockwiseUp];
            }
            else if (railType == 3 || railType == 11) // Turn down
            {
                [self goCounterClockwiseDown];
            }
            else // Halt
            {
                [self comeToAHalt];
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
                [self goCounterClockwiseUp];
            }
            else if (railType == 4 || railType == 12) // Turn down
            {
                [self goClockwiseDown];
            }
            else // Halt
            {
                [self comeToAHalt];
            }
        }
    }
    else // Halt
    {
        [self comeToAHalt];
    }
    xp += deltaH[dir];
    yp += deltaV[dir];
}

-(void)goStraight
{
    newDir = dir;
    float corrX = 0;
    float corrY = 0;
    if (dir == 1 || dir == 2)
    {
        // Check if horizontal needs correction
        corrX = 45.0*roundf(sprite.position.x/45.0)-sprite.position.x;
    }
    else if (dir == 3 || dir == 4)
    {
        // Check if vertical needs correction
        corrY = 30.0*roundf(sprite.position.y/30.0)-sprite.position.y;
    }
    [sprite runAction:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(deltaX[dir]+corrX, deltaY[dir]+corrY) duration:BLOCK_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]]];
}

-(void)comeToAHalt
{
    newDir = 0;
    SKAction *moveAction = [SKAction moveBy:CGVectorMake(deltaX[dir]*0.5, deltaY[dir]*0.5) duration:BLOCK_INTERVAL];
    moveAction.timingMode = SKActionTimingEaseOut;
    [sprite runAction:[SKAction sequence:@[moveAction,[SKAction runBlock:^{[self cartStopped];}]]]];
}

-(void)crash
{
    [owner cartCrashed:self];
}

-(void)goIntoHole
{
    newDir = 0;
    [owner setBlocked:TRUE atH:xp+deltaH[dir] andV:yp+deltaV[dir]];
    // The run block will be executed after xp and yp have been updated
    [sprite runAction:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(deltaX[dir]*0.5, deltaY[dir]*0.5 - 10.0) duration:BLOCK_INTERVAL*0.5],[SKAction runBlock:^{[owner dropCart:self intoHoleAtH:xp andV:yp];}]]]];
}

-(void)cartStopped
{
    [owner cartStopped];
}

-(void)cartLanded
{
    // Unblock hole
    [owner setBlocked:FALSE atH:xp+deltaH[dir] andV:yp+deltaV[dir]];
    [owner cartLanded:self];
}

-(void)goCounterClockwiseDown
{
    newDir = 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -1.0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, M_PI_2, M_PI, FALSE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.counterClockwiseToVerticalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goCounterClockwiseRight
{
    newDir = 4;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(1.0, 0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, M_PI, 3.0*M_PI_2, FALSE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.counterClockwiseToHorizontalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goCounterClockwiseUp
{
    newDir = 1;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 1.0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, 3.0*M_PI_2, 2.0*M_PI, FALSE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.counterClockwiseToVerticalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goCounterClockwiseLeft
{
    newDir = 3;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-1.0, 0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, 0, M_PI_2, FALSE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.counterClockwiseToHorizontalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goClockwiseDown
{
    newDir = 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -1.0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, M_PI_2, 0, TRUE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.clockwiseToVerticalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goClockwiseRight
{
    newDir = 4;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(1.0, 0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, M_PI, M_PI_2, TRUE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.clockwiseToHorizontalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goClockwiseUp
{
    newDir = 1;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 1.0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, 3.0*M_PI_2, M_PI, TRUE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.clockwiseToVerticalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}

-(void)goClockwiseLeft
{
    newDir = 3;
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform t = CGAffineTransformMakeScale(45.0, 30.0);
    t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-1.0, 0), t);
    CGPathAddArc(path, &t, 0, 0, 1.0, 0, 3.0*M_PI_2, TRUE);
    [sprite runAction:[SKAction group:@[[SKAction sequence:@[[SKAction followPath:path asOffset:TRUE orientToPath:FALSE duration:CURVE_INTERVAL],[SKAction runBlock:^{[self stepFinished];}]]],[SKAction animateWithTextures:owner.clockwiseToHorizontalCarts timePerFrame:CURVE_INTERVAL/6.0]]]];
    CFRelease(path);
}


-(void)stepFinished
{
//    NSLog(@"Holder node x,y: %f,%f, sprite x,y: %f,%f",holderNode.position.x,holderNode.position.y,sprite.position.x,sprite.position.y);
    holderNode.position = CGPointMake(holderNode.position.x+deltaX[dir], holderNode.position.y+deltaY[dir]);
    sprite.position = CGPointMake(sprite.position.x-deltaX[dir], sprite.position.y-deltaY[dir]);
    dir = newDir;
    if (newDir > 0)
        [self takeNextStep];
}

-(void)haltMotion
{
    newDir = 0;
}


@end
