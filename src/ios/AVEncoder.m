#import "AVEncoder.h"

#import <AVFoundation/AVAsset.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


#import "CDVJpegHeaderWriter.h"
#import "UIImage+CropScaleOrientation.h"
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <objc/message.h>

#ifndef __CORDOVA_4_0_0
#import <Cordova/NSData+Base64.h>
#endif

@implementation AVEncoder

- (void)encode:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    NSString* start_position = [command.arguments objectAtIndex:1];
    NSString* end_position = [command.arguments objectAtIndex:1];
    
    int start_pos=[start_position intValue];
    int end_pos=[end_position intValue];
    
    
    NSLog(@"PATHHHHHHHHHHH: %@", path);
    
    NSURL *url = [NSURL URLWithString:path];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 1 ;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *image1 = [UIImage imageWithCGImage:imageRef];
    
    NSData *imageData = UIImageJPEGRepresentation(image1, 1.0);
    
    NSLog(@"%@", imageData);
    
    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
    NSLog(@"BASE64: %@", base64String);
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:base64String];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end

