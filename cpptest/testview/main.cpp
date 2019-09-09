//
//  main.m
//  testview
//
//  Created by friday on 2019/8/30.
//  Copyright © 2019 friday. All rights reserved.
//

#include <cstring>
#include <CoreFoundation/CoreFoundation.h>
#include <objc/runtime.h>
#include <objc/message.h>

typedef int(*MainApp)(int,char**,id,CFStringRef);

extern "C"
{
    int UIApplicationMain(int, ...);
    
};


int main(int argc, char * argv[]) {
    
    
    float afloat = 1234.144; // 32 位
    Byte  afloatByte[4];
    memcpy(afloatByte, &afloat, 4);
    
    void * pfloatByte = afloatByte;
    void * pfloat = &afloat;
    CFStringRef strRef = CFSTR("AppDelegate");
    
    id autoreleasePool = objc_msgSend(
                                      (id)objc_msgSend(
                                                       (id)objc_getClass("NSAutoreleasePool"), sel_registerName("alloc")
                                                       ),
                                      sel_registerName("init")
                                      );
    MainApp mainAct = (MainApp)UIApplicationMain;
    mainAct(argc, argv, nil, strRef);
    
    objc_msgSend(autoreleasePool, sel_registerName("drain"));
    return 0;
}
