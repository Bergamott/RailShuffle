//
//  ViewController.m
//  RailShuffle
//
//  Created by Karl on 2015-11-14.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "ViewController.h"
#import "SoundPlayer.h"
#import "GameScene.h"

#define SHUFFLE_TIME 0.5
#define SHUFFLE_WAIT 3.0

#define BUTTON_ANGLE -0.50
#define ANGLE_SIN -0.479
#define ANGLE_COS 0.878

#define FADE_TIME 0.75

@interface ViewController ()

@end

@implementation ViewController

@synthesize gameScene;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Game scene stuff
    SKView * skView = (SKView *)gameView;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    self.gameScene = [GameScene sceneWithSize:skView.bounds.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:gameScene];
    gameScene.owner = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *levelResults = [defaults stringForKey:@"levelStats"];
    if (levelResults == NULL)
    {
        [defaults setObject:DEFAULT_LEVEL_STATS forKey:@"levelStats"];
        [defaults synchronize];
    }
    
#ifdef LITE
    liteBanner.hidden = FALSE;
#else
    liteBanner.hidden = TRUE;
#endif
    
    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;
    
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
    
    [self performSelector:@selector(newArrangement) withObject:NULL afterDelay:SHUFFLE_TIME];
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
    else if (screenWidth<2.0*screenHeight) // Regular iPhone
    {
        playButton.center = CGPointMake(screenWidth-30.0+100.0*ANGLE_COS, 140.0+100.0*ANGLE_SIN);
        helpButton.center = CGPointMake(screenWidth-30.0+150.0*ANGLE_COS, 200.0+150.0*ANGLE_SIN);
        musicButton.center = CGPointMake(screenWidth-30.0+200.0*ANGLE_COS, 259.0+200.0*ANGLE_SIN);
    }
    else // iPhone X or similar
    {
        playButton.center = CGPointMake(screenWidth-80.0+100.0*ANGLE_COS, 170.0+100.0*ANGLE_SIN);
        helpButton.center = CGPointMake(screenWidth-80.0+150.0*ANGLE_COS, 230.0+150.0*ANGLE_SIN);
        musicButton.center = CGPointMake(screenWidth-80.0+200.0*ANGLE_COS, 289.0+200.0*ANGLE_SIN);
    }
    
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:0.6];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        playButton.center = CGPointMake(964.0, 405.0);
    else if (screenWidth<2.0*screenHeight)
        playButton.center = CGPointMake(screenWidth-30.0, 140.0);
    else
        playButton.center = CGPointMake(screenWidth-80.0, 170.0);
    [UIView commitAnimations];
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:0.9];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        helpButton.center = CGPointMake(964.0, 533.0);
    else if (screenWidth<2.0*screenHeight)
        helpButton.center = CGPointMake(screenWidth-30.0, 200.0);
    else
        helpButton.center = CGPointMake(screenWidth-80.0, 230.0);
    [UIView commitAnimations];
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:1.2];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        musicButton.center = CGPointMake(964.0, 655.0);
    else if (screenWidth<2.0*screenHeight)
        musicButton.center = CGPointMake(screenWidth-30.0, 259.0);
    else
        musicButton.center = CGPointMake(screenWidth-80.0, 289.0);
    [UIView commitAnimations];
}

-(void)arrangeLetters:(BOOL)shuffle
{
    int sorter[2][7];
    for (int i=0;i<7;i++)
    {
        sorter[0][i] = i;
        if (shuffle)
            sorter[1][i] = arc4random() & 2047;
        else
            sorter[1][i] = i;
    }
    for (int i=0;i<6;i++)
        for (int j=i+1;j<7;j++)
        {
            if (sorter[1][i] > sorter[1][j])
            {
                int k = sorter[1][i];
                sorter[1][i] = sorter[1][j];
                sorter[1][j] = k;
                k = sorter[0][i];
                sorter[0][i] = sorter[0][j];
                sorter[0][j] = k;
            }
        }
    
    [UIView beginAnimations:@"dummy" context:nil];
    [UIView setAnimationDuration:SHUFFLE_TIME];
    for (int i=0;i<7;i++)
    {
        UIImageView *tmpIV = (UIImageView*)[shuffleLetters objectAtIndex:(NSUInteger)sorter[0][i]];
        tmpIV.center = CGPointMake(letterXPos[i], letterYPos[i]);
        tmpIV.transform = CGAffineTransformMakeRotation(letterAngles[i]);
    }
    [UIView commitAnimations];
}

-(void)newArrangement
{
    shouldShuffle = !shouldShuffle;
    [self arrangeLetters:shouldShuffle];
    [self performSelector:@selector(newArrangement) withObject:NULL afterDelay:shouldShuffle ? SHUFFLE_TIME + 0.2 :SHUFFLE_WAIT];
}


-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}


-(IBAction)playButtonPressed:(id)sender
{
    [[SoundPlayer sharedSoundPlayer] playClick];

    // Set accessible levels
    NSString *results = [[NSUserDefaults standardUserDefaults] stringForKey:@"levelStats"];
    for (int i=0;i<ACTUAL_LEVELS;i++)
    {
        int r = 0;
        BOOL previouslySolved = FALSE;
        if (i < MAX_LEVELS)
        {
            if (i == 0)
                previouslySolved = TRUE;
            else
                previouslySolved = ([results characterAtIndex:i-1] > '0');
            r = [results characterAtIndex:i]-'0';
        }
        UIView *tmpV = [levelView.subviews objectAtIndex:i+1];
        if (previouslySolved)
        {
            tmpV.alpha = 1.0;
            tmpV.userInteractionEnabled = TRUE;
        }
        else if (i<MAX_LEVELS)
        {
            tmpV.alpha = 0.5;
            tmpV.userInteractionEnabled = FALSE;
        }
        else
        {
            tmpV.alpha = 0;
            tmpV.userInteractionEnabled = FALSE;
        }
        // Set plus signs
        for (int j=0;j<3;j++)
        {
            [tmpV.subviews objectAtIndex:j+2].hidden = (j >= r);
        }
    }
    
    levelView.alpha = 0;
    levelView.hidden = FALSE;
    [UIView animateWithDuration:FADE_TIME
                     animations:^{
                         levelView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];
}

-(IBAction)musicButtonPressed:(id)sender
{
    [[SoundPlayer sharedSoundPlayer] playClick];
    SoundPlayer *sp = [SoundPlayer sharedSoundPlayer];
    [sp toggleMusicOn];
    checkbox.hidden = ![sp isMusicOn];
}

-(IBAction)backFromLevelsPressed:(id)sender
{
    [[SoundPlayer sharedSoundPlayer] playClick];
    [UIView animateWithDuration:FADE_TIME
                     animations:^{
                         levelView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         levelView.hidden = TRUE;
                     }];
}

-(IBAction)levelButtonPressed:(id)sender
{
    [[SoundPlayer sharedSoundPlayer] playClick];
    [self prepareGameForLevel:(int)((UIButton*)sender).tag];
}

-(void)prepareGameForLevel:(int)lev
{
    [gameScene setupWithLevel:lev];
    [self fadeInGameScene];
}

-(void)fadeInGameScene
{
    [[SoundPlayer sharedSoundPlayer] stopSong];
    gameView.alpha = 0;
    gameView.hidden = FALSE;
    [UIView animateWithDuration:FADE_TIME
                     animations:^{
                         gameView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         levelView.hidden = TRUE;
                     }];
}

-(void)fadeOutGameScene
{
    levelView.hidden = TRUE;
    [UIView animateWithDuration:FADE_TIME
                     animations:^{
                         gameView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         gameView.hidden = TRUE;
                     }];
    [[SoundPlayer sharedSoundPlayer] playSong:3];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[SoundPlayer sharedSoundPlayer] stopSong];
}

@end
