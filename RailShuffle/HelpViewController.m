//
//  HelpViewController.m
//  RailShuffle
//
//  Created by Karl on 2015-11-15.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "HelpViewController.h"
#import "SoundPlayer.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]isDirectory:NO]]];
    else
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help-iPhone" ofType:@"html"]isDirectory:NO]]];
    for (id tempSubview in webView.subviews){
        if ([[tempSubview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)tempSubview).bounces = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[SoundPlayer sharedSoundPlayer] playSong:3];
}

@end
