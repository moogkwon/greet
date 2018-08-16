//
//  Header.h
//  GriitChat
//
//  Created by leo on 03/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Availability.h>

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCSessionDescription.h>

#import "Reachability.h"

#import <SocketRocket/SRWebSocket.h>
#import <KurentoToolbox/KurentoToolbox.h>

#import "AudioOutputManager.h"

#import "SAVideoRangeSlider.h"

#import <Glimpse/Glimpse.h>

#import <mach/mach.h>

#import <AccountKit/AccountKit.h>

#import "../Inter/Components/SFProgressCircle/SFProgressCircle.h"

float report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
//        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
//        NSLog(@"Memory in use (in MB): %.2f", ((CGFloat)info.resident_size / 1000000));
//        NSLog(@"\n\n");
        return (CGFloat)info.resident_size / 1048576;
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
        return 0;
    }
}
/*
#if TARGET_IPHONE_SIMULATOR
#define Real_Device     false
#else
#define Real_Device     true
#endif

#define Real_Device true*/
/*
#if (arch(i386) || arch(x86_64)) && os(iOS)
#define Real_Device     false
#else
#define Real_Device     true
#endif*/

#endif /* Header_h */
