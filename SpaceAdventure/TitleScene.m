//
//  SpriteMyScene.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/4/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "TitleScene.h"
#import "SpaceshipScene.h"

@interface TitleScene()
@property BOOL contentCreated;
@end

@implementation TitleScene

- (void)didMoveToView:(SKView *)view {
    if(!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:[self newTitleNode]];
    [self addChild:[self newZombie]];
}

- (SKLabelNode *)newTitleNode {
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"Zapfino"];
    titleNode.name = @"titleNode";
    titleNode.text = @"Space Adventure!";
    titleNode.fontSize = 42;
    titleNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return titleNode;
}

- (SKSpriteNode *)newZombie {
    SKSpriteNode *zombie = [SKSpriteNode spriteNodeWithImageNamed:@"Zombie"];
    zombie.position = CGPointMake(CGRectGetMidX(self.frame), 0);
    return zombie;
}

- (void)mouseDown:(NSEvent *)theEvent {
    SKNode *titleNode = [self childNodeWithName:@"titleNode"];
    if(titleNode != nil) {
        titleNode.name = nil;
        SKAction *moveUp = [SKAction moveByX:0 y:100 duration:0.5];
        SKAction *zoom = [SKAction scaleTo:2 duration:.25];
        SKAction *pause = [SKAction waitForDuration:0.5];
        SKAction *fadeAway = [SKAction fadeOutWithDuration:0.25];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
        [titleNode runAction:moveSequence completion:^{
            SKScene *spaceshipScene = [[SpaceshipScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:spaceshipScene transition:doors];
            }];
                                  
    }
}

@end
