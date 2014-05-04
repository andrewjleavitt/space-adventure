//
//  SpriteAppDelegate.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/4/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "SpriteAppDelegate.h"
#import "SpriteMyScene.h"

@implementation SpriteAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *scene = [SpriteMyScene sceneWithSize:CGSizeMake(1024, 768)];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
