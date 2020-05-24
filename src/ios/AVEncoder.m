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
#import "SDAVAssetExportSession.h"

#ifndef __CORDOVA_4_0_0
#import <Cordova/NSData+Base64.h>
#endif

@implementation AVEncoder

- (void)encode:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* path = [command.arguments objectAtIndex:0];
    NSString* start_position = [command.arguments objectAtIndex:1];
    NSString* end_position = [command.arguments objectAtIndex:2];
    
    int start_pos=[start_position intValue];
    int end_pos=[end_position intValue];
    
    NSURL *url = [NSURL fileURLWithPath:path];

    NSString *theFileName = [[url lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.mp4", theFileName,UUID]];
    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]); // Url Should be a file Url, so here we check and convert it into a file Url
    
    
    SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:url]]; // provide inputVideo Url Here
    compressionEncoder.outputFileType = AVFileTypeMPEG4;
    compressionEncoder.outputURL = outputVideoUrl; //Provide output video Url here
    
    CMTime start = CMTimeMakeWithSeconds(start_pos, 600); // you will modify time range here
    CMTime duration = CMTimeSubtract(CMTimeMakeWithSeconds(end_pos, 600), start);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    compressionEncoder.timeRange = range;
    
    compressionEncoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @1024,   //Set your resolution width here
    AVVideoHeightKey: @768,  //set your resolution height here
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @1000000, // Give your bitrate here for lower size give low values
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    compressionEncoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [compressionEncoder exportAsynchronouslyWithCompletionHandler:^
     {
         if (compressionEncoder.status == AVAssetExportSessionStatusCompleted)
         {
             NSLog(@"Compression Export Completed Successfully: %@", finalVideoURLString);

             CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsString:finalVideoURLString];
             
             [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
             
         }
         else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled)
         {
             NSLog(@"Compression Export Canceled");
         }
         else
         {
             NSLog(@"Compression Failed");
             
         }
     }];
    
}


@end

