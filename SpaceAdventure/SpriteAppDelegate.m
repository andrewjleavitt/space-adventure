//
//  SpriteAppDelegate.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/4/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "SpriteAppDelegate.h"
#import "TitleScene.h"

@implementation SpriteAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *title = [TitleScene sceneWithSize:CGSizeMake(1024, 768)];

    /* Set the scale mode to scale to fit the window */
    title.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:title];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
