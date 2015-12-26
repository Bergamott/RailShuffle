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
#define GROUND_Z 0
#define SELECTION_Z 1.0
#define DECORATION_Z 2.0
#define RAIL_Z 3.0
#define OBSTACLE_Z 50.0

#define STATE_PREPARE 0
#define STATE_PLAYING 1

@interface GameScene : SKScene {
    
    SKTextureAtlas *myAtlas;
    SKNode *backgroundNode;
    
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
    NSArray *obstacleNames;
    NSArray *ornamentNames;
    NSMutableArray *cartTextures;
    
    NSMutableArray *carts;
    
    SKSpriteNode *selectionNode;
    int selPos;
    int movingPiece;
    int moveDir;
    float downX,downY;
}

-(void)setupWithLevel:(int)l;
-(void)hideSelection;
-(int)getGroundAtH:(int)h andV:(int)v;

@property(nonatomic,strong) SKTextureAtlas *myAtlas;
@property(nonatomic,strong) SKNode *backgroundNode;
@property(nonatomic,strong) SKSpriteNode *selectionNode;
@property(nonatomic,strong) NSMutableArray *cartTextures;
@property(nonatomic,strong) NSMutableArray *carts;
@end
