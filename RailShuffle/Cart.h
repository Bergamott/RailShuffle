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
    int xp,yp;
    int dir;
    
    GameScene *owner;
}

@end
