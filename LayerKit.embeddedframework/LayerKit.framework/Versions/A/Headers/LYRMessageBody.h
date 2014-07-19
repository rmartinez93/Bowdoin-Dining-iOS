//
//  LYRMessageBody.h
//  LayerKit
//
//  Created by Rok Gregorič on 7. 11. 13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#   import <UIKit/UIKit.h>
typedef UIImage LYRImage;
#else
#   import <AppKit/AppKit.h>
typedef NSImage LYRImage;
#endif

/**
 The `LYRMessageBody` class defines an object that represents a body of a message.
 */

@interface LYRMessageBody : NSObject

/**
 @name Properties
 */

/**
 @abstract The mime type of the body.
 */
@property NSString *mimeType;

/**
 @abstract The content of the body.
 */
@property NSData *data;

/**
 @abstract Creates and returns a new `LYRMessageBody` object with the given mime type and data.
 @param mimeType A string with the message mime type (example: @"text/plain").
 @param data An `NSData` object with the message content.
 @return An `LYRMessageBody` object with the mime type and content set.
 */
+ (instancetype)bodyWithMimeType:(NSString *)mimeType data:(NSData *)data;

/**
 @name Convenience methods
 */

/**
 @abstract Creates and returns a new `LYRMessageBody` object with the mime type set to @"text/plain" and data set to the given text encoded using `NSUTF8StringEncoding`.
 @param text A string with the message content as plain text.
 @return An `LYRMessageBody` object with the mime type set to @"text/plain" and data set to the given text encoded using `NSUTF8StringEncoding`.
 */
+ (instancetype)bodyWithText:(NSString *)text;

/**
 @abstract Creates and returns a new `LYRMessageBody` object with the mime type set to @"image/png" and data set to the given image encoded in PNG format.
 @param image An `LYRImage` object with the message content as an image.
 @return An `LYRMessageBody` object with the mime type set to @"image/png" and data set to the given image encoded in PNG format.
 */
+ (instancetype)bodyWithPNGImage:(LYRImage *)image;

/**
 @abstract Return an `LYRMessageBody` object with the mime type set to @"image/jpeg" and data set to the given image encoded in JPEG format at 99% quality.
 @param image An `LYRImage` object with the message content as an image.
 @return An `LYRMessageBody` object with the mime type set to @"image/png" and data set to the given image encoded in JPEG format at 99% quality.
 */
+ (instancetype)bodyWithJPEGImage:(LYRImage *)image;

/**
 @abstract Test if the receiver's mime type is equal to the given mime type.
 @param mimeType A string with the message mime type to test for.
 @return A Boolean value that determines whether the two mime types are equal.
 */
- (BOOL)isMimeTypeEqualTo:(NSString *)mimeType;

/**
 @abstract Returns a Boolean value that indicates whether a given message body is equal to the receiver.
 @param messageBody The message body with which to compare the receiver.
 @return A Boolean value that determines the two message bodies equality.
 */
- (BOOL)isEqualToMessageBody:(LYRMessageBody *)messageBody;

/**
 @abstract The `NSString` representation of the message content.
 */
- (NSString *)stringRepresentation;

/**
 @abstract The `LYRImage` representation of the message content.
 */
- (LYRImage *)imageRepresentation;

@end

