//
//  SpaceshipScene.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/6/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "SpaceshipScene.h"

@interface SpaceshipScene ()
@property BOOL contentCreated;
@property (nonatomic) BOOL moveForward;
@property (nonatomic) BOOL moveLeft;
@property (nonatomic) BOOL moveRight;
@property (nonatomic) BOOL moveBack;
@property (nonatomic) BOOL fireAction;
@end

@implementation SpaceshipScene


- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    SKSpriteNode *spaceship = [self newSpaceship];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame),                              CGRectGetMidY(self.frame)-300);
    [self addChild:spaceship];
}

- (SKSpriteNode *) newLight {
    SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.25],
                                           [SKAction fadeInWithDuration:0.25]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [light runAction: blinkForever];
    
    return light;
}

- (SKSpriteNode *)newSpaceship {
    SKSpriteNode *hull = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(64, 32)];
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(-28.0, 6.0);
    [hull addChild:light1];
    
    SKSpriteNode *light1b = [self newLight];
    light1b.position = CGPointMake(-28.0, -6.0);
    [hull addChild:light1b];
    
    SKSpriteNode *light2 = [self newLight];
    light2.position = CGPointMake(28.0, 6.0);
    [hull addChild:light2];
    
    SKSpriteNode *light2b = [self newLight];
    light2b.position = CGPointMake(28.0, -6.0);
    [hull addChild:light2b];
    hull.name = @"hull";
    return hull;
}


- (void)move {
    SKNode *spaceShip = [self childNodeWithName:@"hull"];
    SKAction *action = nil;
    // Build up the movement action.
    if(self.moveForward == YES) {
        action = [SKAction moveByX:0 y:10 duration:0.25];
    }
    if(self.moveBack == YES) {
        action = [SKAction moveByX:0 y:-10 duration:0.25];
    }
    if(self.moveLeft == YES) {
        action = [SKAction moveByX:-10 y:0 duration:0.25];
    }
    if(self.moveRight == YES) {
        action = [SKAction moveByX:10 y:0 duration:0.25];
    }
    
    // Play the resulting action.
    if (action) {
        [spaceShip runAction:action];
    }
}


- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:YES];
}

- (void)keyUp:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:NO];
}
- (void)handleKeyEvent:(NSEvent *)event keyDown:(BOOL)downOrUp {
    // Now check the rest of the keyboard
    NSString *characters = [event characters];
//    NSLog(characters);
    for (int s = 0; s<[characters length]; s++) {
        unichar character = [characters characterAtIndex:s];
        switch (character) {
            case 'w':
                self.moveForward = downOrUp;
                break;
            case 'a':
                self.moveLeft = downOrUp;
                break;
            case 'd':
                self.moveRight = downOrUp;
                break;
            case 's':
                self.moveBack = downOrUp;
                break;
            case ' ':
                self.fireAction = downOrUp;
                break;
        }
    }
}


- (void)update:(NSTimeInterval)currentTime {
    [self move];


}

@end