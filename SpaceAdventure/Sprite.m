//
//  Sprite.m
//  SpaceAdventure
//
//  Created by Andy Leavitt on 5/8/14.
//  Copyright (c) 2014 Andy. All rights reserved.
//

#import "Sprite.h"

@implementation Sprite


CGSize coverageSize = CGSizeMake(2000,2000); //the size of the entire image you want tiled
CGRect textureSize = CGRectMake(0, 0, 100, 100); //the size of the tile.
CGImageRef backgroundCGImage = [UIImage imageNamed:@"image_to_tile"].CGImage; //change the string to your image name
UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
CGContextRef context = UIGraphicsGetCurrentContext();
CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
backgroundTiles.yScale = -1; //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
backgroundTiles.position = CGPointMake(0,0);
[self addChild:backgroundTiles];


@end
