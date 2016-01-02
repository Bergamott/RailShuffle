//
//  Cart.h
//  RailShuffle
//
//  Created by Karl on 2015-12-26.
//  Copyright © 2015 Karl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class GameScene;

@interface Cart : NSObject {
    
    SKSpriteNode *sprite;
    SKNode *holderNode;
    int xp,yp;
    int dir;
    int newDir;
    int lastPos;
    BOOL active;
    
    GameScene *owner;
}

-(id)initWithOwner:(GameScene*)o xPos:(int)x yPos:(int)y andDir:(int)d;

-(void)getGoing;
-(void)stepFinished;
-(void)takeNextStep;
-(void)goStraight;
-(void)comeToAHalt;
-(void)goIntoHole;
-(void)crash;
-(void)cartStopped;
-(void)cartLanded;
-(void)goCounterClockwiseDown;
-(void)goCounterClockwiseRight;
-(void)goCounterClockwiseUp;
-(void)goCounterClockwiseLeft;
-(void)goClockwiseDown;
-(void)goClockwiseRight;
-(void)goClockwiseUp;
-(void)goClockwiseLeft;

-(void)haltMotion;

@property(nonatomic,strong) SKNode *holderNode;
@property(nonatomic,strong) SKSpriteNode *sprite;
@property(nonatomic) int xp;
@property(nonatomic) int yp;
@property(nonatomic) BOOL active;

@end
