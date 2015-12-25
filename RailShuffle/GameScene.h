//
//  GameScene.h
//  RailShuffle
//
//  Created by Karl on 2015-12-24.
//  Copyright © 2015 Karl. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>

@interface GameScene : SKScene {
    
    SKTextureAtlas *myAtlas;
    SKNode *backgroundNode;
    
    int level;
    int grid[12][14];
    float gridBaseX,gridBaseY;
    float xScale,yScale;
    float screenHeight;
    float topXScale;
    
    NSArray *topNames;
    NSArray *groundNames;
}

-(void)setupWithLevel:(int)l;

@property(nonatomic,strong) SKTextureAtlas *myAtlas;
@property(nonatomic,strong) SKNode *backgroundNode;

@end
