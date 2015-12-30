//
//  SoundPlayer.m
//  RailShuffle
//
//  Created by Karl on 2015-11-22.
//  Copyright © 2015 Karl. All rights reserved.
//

#import "SoundPlayer.h"

@implementation SoundPlayer

+(SoundPlayer*)sharedSoundPlayer
{
    static SoundPlayer *sharedSoundPlayer;
    
    @synchronized(self)
    {
        if (!sharedSoundPlayer)
        {
            sharedSoundPlayer = [[SoundPlayer alloc] init];
        }
        return sharedSoundPlayer;
    }
}

-(void)setSoundOn:(BOOL)b
{
    soundOn = b;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!soundOn forKey:@"soundMute"];
    [defaults synchronize];
}

-(BOOL)isMusicOn
{
    return musicOn;
}

-(void)toggleMusicOn
{
    BOOL newState = !musicOn;
    [self setMusicOn:newState];
}

-(void)setMusicOn:(BOOL)b
{
    if (!b && musicOn && currentSong >= 0)
    {
        [(AVAudioPlayer*)[musicPlayers objectAtIndex:currentSong] stop];
    }
    else if (b && !musicOn && currentSong >= 0)
    {
        AVAudioPlayer *currentPlayer = [musicPlayers objectAtIndex:currentSong];
        [currentPlayer prepareToPlay];
        [currentPlayer play];
    }
    musicOn = b;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!musicOn forKey:@"musicMute"];
    [defaults synchronize];
}

-(void)loadSounds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    soundOn = ![defaults boolForKey:@"soundMute"];
    musicOn = ![defaults boolForKey:@"musicMute"];
    currentSong = -1;
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"chime" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &chimeSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &clickSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &crashSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"fanfare" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &fanfareSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"gong" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &gongSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"sad" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &sadSound);
    audioPath = [[NSBundle mainBundle] URLForResource:@"slide" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &slideSound);
    
    NSArray *songs = @[@"clementine",@"mountain",@"yankee",@"susanna"];
    musicPlayers = [NSMutableArray arrayWithCapacity:4];
    
    for (int i=0;i<4;i++)
    {
        NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:[songs objectAtIndex:i] ofType:@"mp3"];
        NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
        AVAudioPlayer *backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
        backgroundMusicPlayer.delegate = self;  // We need this so we can restart after interruptions
        backgroundMusicPlayer.numberOfLoops = -1;  // Negative number means loop forever
        [musicPlayers addObject:backgroundMusicPlayer];
    }
}

-(void)playChime
{
    if (soundOn)
        AudioServicesPlaySystemSound(chimeSound);
}
-(void)playClick
{
    if (soundOn)
        AudioServicesPlaySystemSound(clickSound);
}
-(void)playCrash
{
    if (soundOn)
        AudioServicesPlaySystemSound(crashSound);
}
-(void)playFanfare
{
    if (soundOn)
        AudioServicesPlaySystemSound(fanfareSound);
}
-(void)playGong
{
    if (soundOn)
        AudioServicesPlaySystemSound(gongSound);
}
-(void)playSad
{
    if (soundOn)
        AudioServicesPlaySystemSound(sadSound);
}
-(void)playSlide
{
    if (soundOn)
        AudioServicesPlaySystemSound(slideSound);
}


-(void)playSong:(int)s
{
    if (currentSong != s)
    {
        if (musicOn)
        {
            if (currentSong >= 0)
            {
                [(AVAudioPlayer*)[musicPlayers objectAtIndex:currentSong] stop];
            }
            AVAudioPlayer *newPlayer = [musicPlayers objectAtIndex:s];
            [newPlayer prepareToPlay];
            [newPlayer play];
        }
    }
    currentSong = s;
}

-(void)stopSong
{
    if (currentSong >= 0 && musicOn)
    {
        [(AVAudioPlayer*)[musicPlayers objectAtIndex:currentSong] stop];
    }
    currentSong = -1;
}

-(void)audioPlayerBeginInterruption: (AVAudioPlayer *) player {

}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags{
    
    if (musicOn && currentSong >= 0)
    {
        AVAudioPlayer *newPlayer = [musicPlayers objectAtIndex:currentSong];
        [newPlayer prepareToPlay];
        [newPlayer play];
    }
}


@end
