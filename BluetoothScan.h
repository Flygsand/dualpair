/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#ifndef __DUALPAIR__BLUETOOTH_SCAN_H__
#define __DUALPAIR__BLUETOOTH_SCAN_H__

#import <Foundation/Foundation.h>
#import <IOBluetooth/objc/IOBluetoothDeviceInquiry.h>

@interface BluetoothScan : NSObject<IOBluetoothDeviceInquiryDelegate>
{

    IOBluetoothDeviceInquiry *inquiry;
    bool completed;
}

- (void) start;
- (void) stop;
- (NSArray *) foundDevices;

@end

#endif