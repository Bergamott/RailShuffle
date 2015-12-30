//
//  SoundPlayer.h
//  RailShuffle
//
//  Created by Karl on 2015-11-22.
//  Copyright © 2015 Karl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer : NSObject <AVAudioPlayerDelegate> {
    
    BOOL soundOn;
    BOOL musicOn;
    
    SystemSoundID chimeSound;
    SystemSoundID clickSound;
    SystemSoundID crashSound;
    SystemSoundID fanfareSound;
    SystemSoundID gongSound;
    SystemSoundID sadSound;
    SystemSoundID slideSound;
    
    NSMutableArray *musicPlayers;
    int currentSong;
}

+(SoundPlayer*)sharedSoundPlayer;

-(void)setSoundOn:(BOOL)b;
-(void)setMusicOn:(BOOL)b;

-(BOOL)isMusicOn;
-(void)toggleMusicOn;

-(void)loadSounds;

-(void)playChime;
-(void)playClick;
-(void)playCrash;
-(void)playFanfare;
-(void)playGong;
-(void)playSad;
-(void)playSlide;

-(void)playSong:(int)s;
-(void)stopSong;

@end
