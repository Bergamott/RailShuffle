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
    
    GameScene *owner;
}

-(id)initWithOwner:(GameScene*)o xPos:(int)x yPos:(int)y andDir:(int)d;

-(void)getGoing;
-(void)stepFinished;
-(void)takeNextStep;
-(void)goStraight;

@property(nonatomic,strong) SKNode *holderNode;

@end
