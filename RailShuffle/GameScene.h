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
    
    NSArray *topNames;
    NSArray *groundNames;
    NSArray *edgeNames;
    NSArray *obstacleNames;
    NSArray *ornamentNames;
    
    SKSpriteNode *selectionNode;
    int selPos;
}

-(void)setupWithLevel:(int)l;
-(void)hideSelection;

@property(nonatomic,strong) SKTextureAtlas *myAtlas;
@property(nonatomic,strong) SKNode *backgroundNode;
@property(nonatomic,strong) SKSpriteNode *selectionNode;

@end
