//
//  MHMediaHelper.h
//  MyHoard
//
//  Created by Milena Gnoińska on 25.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHMedia.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MHMedia (Images)

- (UIImage*) thumbnail;
- (UIImage*) image;

@end
