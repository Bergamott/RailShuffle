//
//  ViewController.m
//  RailShuffle
//
//  Created by Karl on 2015-11-14.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "ViewController.h"
#import "SoundPlayer.h"

#define SHUFFLE_TIME 0.5
#define SHUFFLE_WAIT 3.0

#define BUTTON_ANGLE -0.50
#define ANGLE_SIN -0.479
#define ANGLE_COS 0.878

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    screenWidth = self.view.frame.size.width;
    
    shuffleLetters = [[NSArray alloc] initWithObjects:letter0,letter1,letter2,letter3,letter4,letter5,letter6, nil];
    for (int i=0;i<7;i++)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            letterXPos[i] = 500.0 + 72.0*(i-3);
            letterYPos[i] = 250.0 + 4.5*(i-3)*(i-3);
        }
        else // iPhone
        {
            letterXPos[i] = screenWidth*0.5 - 5.0 + 36.0*(i-3);
            letterYPos[i] = 122.0 + 2.5*(i-3)*(i-3);
        }
        letterAngles[i] = 0.12*(i-3);
        UIImageView *tmpIV = (UIImageView*)[shuffleLetters objectAtIndex:(NSUInteger)i];
        tmpIV.center = CGPointMake(letterXPos[i], letterYPos[i]);
        tmpIV.transform = CGAffineTransformMakeRotation(letterAngles[i]);
    }
    shouldShuffle = FALSE;
    [self setupButtons];
    [[SoundPlayer sharedSoundPlayer] playSong:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return TRUE;
}

-(void)setupButtons
{
    playButton.transform = CGAffineTransformMakeRotation(BUTTON_ANGLE);
    helpButton.transform = CGAffineTransformMakeRotation(BUTTON_ANGLE);
    musicButton.transform = CGAffineTransformMakeRotation(BUTTON_ANGLE);
    
    checkbox.hidden = ![[SoundPlayer sharedSoundPlayer] isMusicOn];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        playButton.center = CGPointMake(964.0+200.0*ANGLE_COS, 405.0+200.0*ANGLE_SIN);
        helpButton.center = CGPointMake(964.0+300.0*ANGLE_COS, 533.0+300.0*ANGLE_SIN);
        musicButton.center = CGPointMake(964.0+400.0*ANGLE_COS, 655.0+400.0*ANGLE_SIN);
    }
    else // iPhone
    {
        playButton.center = CGPointMake(screenWidth-30.0+100.0*ANGLE_COS, 140.0+100.0*ANGLE_SIN);
        helpButton.center = CGPointMake(screenWidth-30.0+150.0*ANGLE_COS, 200.0+150.0*ANGLE_SIN);
        musicButton.center = CGPointMake(screenWidth-30.0+200.0*ANGLE_COS, 259.0+200.0*ANGLE_SIN);
    }
    
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:0.6];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        playButton.center = CGPointMake(964.0, 405.0);
    else
        playButton.center = CGPointMake(screenWidth-30.0, 140.0);
    [UIView commitAnimations];
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:0.9];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        helpButton.center = CGPointMake(964.0, 533.0);
    else
        helpButton.center = CGPointMake(screenWidth-30.0, 200.0);
    [UIView commitAnimations];
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:1.2];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        musicButton.center = CGPointMake(964.0, 655.0);
    else
        musicButton.center = CGPointMake(screenWidth-30.0, 259.0);
    [UIView commitAnimations];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}


-(IBAction)playButtonPressed:(id)sender
{
    
}

-(IBAction)musicButtonPressed:(id)sender
{
    SoundPlayer *sp = [SoundPlayer sharedSoundPlayer];
    [sp toggleMusicOn];
    checkbox.hidden = ![sp isMusicOn];
}


@end
