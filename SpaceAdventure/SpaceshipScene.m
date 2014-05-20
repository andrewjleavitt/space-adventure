//
//  SpaceshipScene.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/6/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "SpaceshipScene.h"
#import "StarField.h"

@interface SpaceshipScene ()
@property BOOL contentCreated;
@property (nonatomic) BOOL moveForward;
@property (nonatomic) BOOL moveLeft;
@property (nonatomic) BOOL moveRight;
@property (nonatomic) BOOL moveBack;
@property (nonatomic) BOOL fireAction;
@property (nonatomic) NSTimeInterval lastShotFireTime;

@property (nonatomic) NSTimeInterval lastUpdateTime;

@property (nonatomic) SKSpriteNode* spaceship;
@property (nonatomic) SKSpriteNode* bg1;
@property (nonatomic) SKSpriteNode* bg2;
@property (nonatomic) NSNumber* scrollSpeed;

@end

@implementation SpaceshipScene


- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
//    [self setScrollSpeed: [NSNumber 2.0]];
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.anchorPoint = CGPointMake(0, 0);
        [self setBg1:[self newBackground]];
    [self setBg2:[self newBackground]];
    
    self.bg1.anchorPoint = CGPointZero;
    self.bg1.position = CGPointMake(0, 0);
    self.bg1.name = @"bg1";
    [self addChild:self.bg1];

    self.bg2.anchorPoint = CGPointZero;
    self.bg2.position = CGPointMake(0, self.bg1.size.height - 1);
    self.bg2.name = @"bg2";
    [self addChild:self.bg2];
    
    StarField *starField = [StarField node];
    [self addChild:starField];

    
    [self setSpaceship:[self newSpaceship]];
    self.spaceship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-300);
    self.spaceship.zPosition = 100;
    [self addChild:self.spaceship];
    
//    SKAction *makeRocks = [SKAction sequence: @[
//                                                [SKAction performSelector:@selector(addRock) onTarget:self],
//                                                [SKAction waitForDuration:0.10 withRange:0.15]
//                                                ]];
//    [self runAction: [SKAction repeatActionForever:makeRocks]];
}

- (SKSpriteNode *)newSpaceship {
    //    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    //    hull.scale = 0.25;
    SKSpriteNode *hull = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(32, 32)];
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
    
    hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
    
    hull.physicsBody.dynamic = NO;
    hull.name = @"hull";
    return hull;
}

- (SKSpriteNode *) newMissile {
    SKSpriteNode *missile = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(8, 24)];
    return missile;
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


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)addRock
{
    SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(8,8)];
    rock.position = CGPointMake(skRand(-512, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.zPosition = 2;
    [self addChild:rock];
}

- (SKSpriteNode *) newRock:(CGFloat)size {
//    SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(size,size)];
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"Zombie"];
    rock.size = CGSizeMake(size, size);
    return rock;
}

- (void) dropAsteroid {
    CGFloat sideSize = 30 + arc4random_uniform(30);
    CGFloat maxX = self.size.width;
    CGFloat quarterX = maxX / 4;
    CGFloat startX = arc4random_uniform(maxX + (quarterX *2)) - quarterX;
    CGFloat startY = self.size.height + sideSize;
    CGFloat endX = arc4random_uniform(maxX);
    CGFloat endY= 0 - sideSize;
    
    SKSpriteNode *rock = [self newRock:sideSize];
    rock.position = CGPointMake(startX, startY);
    rock.name = @"rock";
    [self addChild:rock];
    SKAction *move = [SKAction moveTo:CGPointMake(endX, endY) duration:3+arc4random_uniform(4)];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *travelAndRemove = [SKAction sequence:@[move,remove]];
    
    SKAction *spin = [SKAction rotateByAngle:3 duration:arc4random_uniform(2)+ 1];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    
    SKAction *all = [SKAction group:@[spinForever, travelAndRemove]];
    [rock runAction:all];
                                 
}


- (void) shoot {
    SKSpriteNode *missile = [self newMissile];
    missile.name = @"missile";
    missile.position = self.spaceship.position;
    [self addChild:missile];
    SKAction *fly = [SKAction moveByX:0 y:self.size.height+missile.size.height duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *fireAndRemove = [SKAction sequence:@[fly, remove]] ;
    [missile runAction:fireAndRemove];
}

- (void)movePlayer {
    SKAction *action = nil;
    // Build up the movement action.
    if(self.moveForward == YES) {
        action = [SKAction moveByX:0 y:10 duration:0.1];
    }
    if(self.moveBack == YES) {
        action = [SKAction moveByX:0 y:-10 duration:0.1];
    }
    if(self.moveLeft == YES) {
        action = [SKAction moveByX:-10 y:0 duration:0.1];
    }
    if(self.moveRight == YES) {
        action = [SKAction moveByX:10 y:0 duration:0.1];
    }
    if(self.fireAction == YES) {
        [self shoot];
    }
    
    // Play the resulting action.
    if (action) {
        [self.spaceship runAction:action];
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


- (SKSpriteNode *)newBackground {
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"StarMap4"];
    background.zPosition = 0;
    background.scale = 1;
    NSLog(@"create a background");
    return background;
}

- (void)scrollBackground {
//    [self setScrollSpeed:self.scrollSpeed * 1.25];
    self.bg1.position = CGPointMake(self.bg1.position.x, self.bg1.position.y - 3);
    self.bg2.position = CGPointMake(self.bg2.position.x, self.bg2.position.y - 3);
    
    if(self.bg1.position.y < -self.bg1.size.height - self.bg1.size.height/2) {
        self.bg1.position = CGPointMake(self.bg1.position.x, self.bg2.size.height + self.bg2.position.y);
    }
    if(self.bg2.position.y < -self.bg2.size.height - self.bg2.size.height/2) {
        self.bg2.position = CGPointMake(self.bg2.position.x, self.bg1.size.height + self.bg1.position.y);
    }
}

- (void) checkCollisions {
    
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *rock, BOOL *stop) {
        // player death
        if([self.spaceship intersectsNode:rock]) {
            [self.spaceship removeFromParent];
            [rock removeFromParent];
        }
        // missile hit
        [self enumerateChildNodesWithName:@"missile" usingBlock:^(SKNode *missile, BOOL *stop) {
            if([missile intersectsNode:rock]) {
                [missile removeFromParent];
                [rock removeFromParent];
                *stop = YES;
            }
        }];

    }];
    
    }

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}

- (void)update:(NSTimeInterval)currentTime {
    
    if(self.lastUpdateTime == 0) {
        self.lastUpdateTime = currentTime;
    }
//    NSTimeInterval timeDelta = currentTime - self.lastUpdateTime;
    
    [self movePlayer];
    [self scrollBackground];
    
    if (arc4random_uniform(1000) <= 15) {
        [self dropAsteroid];
    }
    
    [self checkCollisions];
    
    self.lastUpdateTime = currentTime;

}

@end