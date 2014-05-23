//
//  SpaceshipScene.m
//  SpaceAdventure
//
//  Created by Andrew Leavitt on 5/6/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "SpaceshipScene.h"
#import "StarField.h"
#import "PocketSVG.h"

#define kScoreHudName @"scoreHud"

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
@property NSUInteger score;

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
    [self setupHud];
    
//    SKAction *makeRocks = [SKAction sequence: @[
//                                                [SKAction performSelector:@selector(addRock) onTarget:self],
//                                                [SKAction waitForDuration:0.10 withRange:0.15]
//                                                ]];
//    [self runAction: [SKAction repeatActionForever:makeRocks]];
}


-(void)adjustScoreBy:(NSUInteger)points {
    self.score += points;
    SKLabelNode* score = (SKLabelNode*)[self childNodeWithName:kScoreHudName];
    score.text = [NSString stringWithFormat:@"Score: %04lu", (unsigned long)self.score];
}

-(void)setupHud {
    SKLabelNode* score = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    //1
    score.name = kScoreHudName;
    score.fontSize = 15;
    //2
    score.fontColor = [SKColor greenColor];
    score.text = [NSString stringWithFormat:@"Score: %04d", 0];
    //3
    score.position = CGPointMake(20 + score.frame.size.width/2, self.size.height - (20 + score.frame.size.height/2));
    [self addChild:score];
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


- (SKSpriteNode *) newEnemySpaceShip {
    SKSpriteNode *enemyHull = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(64, 16)];

    SKSpriteNode *gunl = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(8, 24)];
    SKSpriteNode *gunr = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(8, 24)];
    
    gunl.position = CGPointMake(-32, 8);
    gunr.position = CGPointMake(32, 8);
    
    [enemyHull addChild:gunl];
    [enemyHull addChild:gunr];
    
    enemyHull.name = @"enemyHull";
    enemyHull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemyHull.size];
    enemyHull.physicsBody.dynamic = NO;
    
    return enemyHull;
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

- (void) dropThing {
    u_int32_t dice = arc4random_uniform(100);
    if (dice < 15) {
        [self dropEnemyShip];
    } else {
        [self dropAsteroid];
    }
    
}

- (void) dropEnemyShip {
    CGFloat sideSize = 30;
    CGFloat startX = arc4random_uniform(self.size.width - 40) + 20;
    CGFloat startY = self.size.height + sideSize;
    
    SKSpriteNode *enemy = [self newEnemySpaceShip];
//    enemy.size = CGSizeMake(sideSize, sideSize);
    enemy.position = CGPointMake(startX, startY);
    enemy.name = @"enemy";
    [self addChild:enemy];
    
    CGPathRef shipPath = [self buildEnemyShipMovementPath];
    SKAction *followPath = [SKAction followPath:shipPath asOffset:YES orientToPath:YES duration:7];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *all = [SKAction sequence:@[followPath, remove]];
    [enemy runAction:all];
}

- (CGPathRef)buildEnemyShipMovementPath
{
    CGPathRef path = [PocketSVG pathFromSVGFileNamed:@"enemy1path"];
    return path;
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
        // player death by asteroid
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
                [self adjustScoreBy:1];
            }
        }];

    }];
    
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *enemy, BOOL *stop) {
        if([self.spaceship intersectsNode:enemy]) {
            [self.spaceship removeFromParent];
            [enemy removeFromParent];
        }
        // missile hit
        [self enumerateChildNodesWithName:@"missile" usingBlock:^(SKNode *missile, BOOL *stop) {
            if([missile intersectsNode:enemy]) {
                [missile removeFromParent];
                [enemy removeFromParent];
                *stop = YES;
                [self adjustScoreBy:10];
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
    
    if (currentTime - self.lastShotFireTime > 0.2 && self.fireAction == YES) {
        [self shoot];
        self.lastShotFireTime = currentTime;
    }
    
    if (arc4random_uniform(1000) <= 15) {
        [self dropThing];
    }
    
    [self checkCollisions];
    
    self.lastUpdateTime = currentTime;

}



@end