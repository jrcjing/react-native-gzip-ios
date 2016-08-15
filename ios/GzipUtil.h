//
//  GzipUtil.h
//  xyqcbg2
//
//  Created by Lisa on 16/8/12.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GzipUtil : NSObject <RCTBridgeModule>

+ (NSData *)gZipData:(NSData *)data;

+ (NSString *)gZipString:(NSString *)string;

@end
