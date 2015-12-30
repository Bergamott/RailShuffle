//
//  GameScene.h
//  RailShuffle
//
//  Created by Karl on 2015-12-24.
//  Copyright © 2015 Karl. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>

#define GRIDW 14
#define GRIDH 12

#define GROUND_HOLE 0
#define GROUND_FIXED 32
#define GROUND_MOBILE 64
#define GROUND_SELECTED 96

#define CONTENT_RAIL 128
#define CONTENT_OBSTACLE 256

#define HOLE_Z -2.0
#define FRONT_HOLE_Z -1.0
#define FALL_Z -1.0
#define GROUND_Z 0
#define SELECTION_Z 1.0
#define DECORATION_Z 2.0
#define RAIL_Z 3.0
#define SHADOW_Z 4.0
#define OBSTACLE_Z 50.0

#define STATE_PREPARE 0
#define STATE_PLAYING 1
#define STATE_SOLVED 2
#define STATE_FAIL 3

@class ViewController;
@class SoundPlayer;
@class Cart;

@interface GameScene : SKScene {
    
    SKTextureAtlas *myAtlas;
    SKNode *backgroundNode;
    BOOL isPad;
    
    int level;
    int natureType;
    int groundMap[GRIDH][GRIDW];
    float gridBaseX,gridBaseY;
    float xScale,yScale;
    float screenHeight;
    float topXScale;
    int numBags;
    int numCarts;
    int gameState;
    
    NSArray *topNames;
    NSArray *groundNames;
    NSArray *edgeNames;
    NSArray *flatNames;
    NSArray *obstacleNames;
    NSArray *ornamentNames;
    NSMutableArray *cartTextures;
    NSArray *counterClockwiseToVerticalCarts;
    NSArray *clockwiseToVerticalCarts;
    NSArray *counterClockwiseToHorizontalCarts;
    NSArray *clockwiseToHorizontalCarts;
    
    NSMutableArray *carts;
    
    SKSpriteNode *selectionNode;
    int selPos;
    int movingPiece;
    SKSpriteNode *frontHole;
    int newPos;
    int moveDir;
    float downX,downY;
    
    SKNode *exitSignHolder;
    SKSpriteNode *exitCross;
    SKNode *levelSignHolder;
    SKSpriteNode *digit0;
    SKSpriteNode *digit1;
    SKNode *timerSignHolder;
    SKSpriteNode *timerBar;
    BOOL exitSignPressed;
    
    CGPoint exitSignOut;
    CGPoint exitSignIn;
    CGPoint levelSignOut;
    CGPoint levelSignIn;
    CGPoint timerSignOut;
    CGPoint timerSignIn;
    
    ViewController *owner;
    SoundPlayer *player;
}

-(void)prepareSigns;
-(void)setupWithLevel:(int)l;
-(void)startLevel;
-(void)animateSignsIn;
-(void)animateSignsOut;
-(void)hideSelection;
-(int)getGroundAtH:(int)h andV:(int)v;
-(void)finishedSliding;
-(void)checkForBagAt:(int)pos withCartZ:(float)z;
-(void)checkForSolved;
-(void)checkForFailed;
-(void)exitPressed;
-(void)cartStopped;
-(void)cartCrashed:(Cart*)c;

@property(nonatomic,strong) SKTextureAtlas *myAtlas;
@property(nonatomic,strong) SKNode *backgroundNode;
@property(nonatomic,strong) SKSpriteNode *selectionNode;
@property(nonatomic,strong) NSMutableArray *cartTextures;
@property(nonatomic,strong) NSMutableArray *carts;
@property(nonatomic,strong) SKSpriteNode *frontHole;
@property(nonatomic,strong) NSArray *counterClockwiseToVerticalCarts;
@property(nonatomic,strong) NSArray *clockwiseToVerticalCarts;
@property(nonatomic,strong) NSArray *counterClockwiseToHorizontalCarts;
@property(nonatomic,strong) NSArray *clockwiseToHorizontalCarts;

@property(nonatomic,strong) ViewController *owner;

@end
