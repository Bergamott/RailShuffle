//
//  ViewController.h
//  RailShuffle
//
//  Created by Karl on 2015-11-14.
//  Copyright © 2015 Karl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    IBOutlet UIButton* playButton;
    IBOutlet UIButton* helpButton;
    IBOutlet UIView* musicButton;
    IBOutlet UIImageView* checkbox;
    
    IBOutlet UIImageView* letter0;
    IBOutlet UIImageView* letter1;
    IBOutlet UIImageView* letter2;
    IBOutlet UIImageView* letter3;
    IBOutlet UIImageView* letter4;
    IBOutlet UIImageView* letter5;
    IBOutlet UIImageView* letter6;
    NSArray *shuffleLetters;
    float letterAngles[7],letterXPos[7],letterYPos[7];
    BOOL shouldShuffle;
    
    float screenWidth;
    
    IBOutlet UIView *levelView;

}

-(void)setupButtons;
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;

-(void)arrangeLetters:(BOOL)shuffle;
-(void)newArrangement;

-(IBAction)playButtonPressed:(id)sender;
-(IBAction)musicButtonPressed:(id)sender;
-(IBAction)backFromLevelsPressed:(id)sender;

@end

