//
//  LYRDevice.h
//  LayerKit
//
//  Created by Rok Gregorič on 14. 08. 13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

/**
 Possible `LYRDevice` types.
 */
typedef NS_ENUM(NSInteger, LYRDeviceType) {
    /** An Andoid device. */
    LYRDeviceTypeAndroid = 1,
    /** A iOS device. */
    LYRDeviceTypeIOS = 2,
    /** A Web browser. */
    LYRDeviceTypeWEB = 3,
};

/**
 The `LYRDevice` class defines a device object, containing device information.
 */

@interface LYRDevice : NSObject

/**
 @name Properties
 */

/**
 @abstract The device's identifier.
 */
@property (nonatomic, readonly) NSString *deviceId;

/**
 @abstract The device's manufacturer.
 */
@property (nonatomic, readonly) NSString *manufacturer;

/**
 @abstract The device's model version.
 */
@property (nonatomic, readonly) NSString *modelVersion;

/**
 @abstract The device's name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 @abstract The device's operating system identifier.
 */
@property (nonatomic, readonly) NSString *os;

/**
 @abstract The device's operating system version.
 */
@property (nonatomic, readonly) NSString *osVersion;

/**
 @abstract The device's APN token.
 */
@property (nonatomic, readonly) NSString *apnToken;

/**
 @abstract The device type.
 */
@property (nonatomic, readonly) LYRDeviceType type;

/**
 @abstract Returns a Boolean value that indicates whether a given device is equal to the receiver.
 @param device The device with which to compare the receiver.
 @return A Boolean value that determines the two devices equality.
 */
- (BOOL)isEqualToDevice:(LYRDevice *)device;

@end
