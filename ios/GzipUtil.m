//
//  GzipUtil.m
//  GzipUtil
//
//  Created by Lisa on 16/8/16.
//  Copyright © 2016年 Lisa. All rights reserved.
//

#import "GzipUtil.h"
#import <zlib.h>
#import <dlfcn.h>

static int DefaltGzipLevel = -1;

@implementation GzipUtil

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(gZipString:(NSString *)string
                  callback:(RCTResponseSenderBlock)callback)
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzipData = [GzipUtil gZipData:data];
    NSData *gzipBase64Data = [gzipData base64EncodedDataWithOptions:0];
    NSString *zipStr = [NSString stringWithUTF8String:[gzipBase64Data bytes]];
    if(zipStr){
        return callback(@[[NSNull null], zipStr]);
    }
    return callback(@[[NSString stringWithFormat:@"GZip failed: %@", string]]);
}

+ (NSData *)gZipData:(NSData *)input{
    if (input.length == 0 || [GzipUtil isGzippedData:input]) {
        return input;
    }
    
    void *libz = dlopen("/usr/lib/libz.dylib", RTLD_LAZY);
    int (*deflateInit2_)(z_streamp, int, int, int, int, int, const char *, int) = dlsym(libz, "deflateInit2_");
    int (*deflate)(z_streamp, int) = dlsym(libz, "deflate");
    int (*deflateEnd)(z_streamp) = dlsym(libz, "deflateEnd");
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)input.length;
    stream.next_in = (Bytef *)input.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger RCTGZipChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = (DefaltGzipLevel < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(DefaltGzipLevel * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:RCTGZipChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += RCTGZipChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    dlclose(libz);
    
    return output;
}

+ (BOOL)isGzippedData:(NSData *__nonnull)data{
    UInt8 *bytes = (UInt8 *)data.bytes;
    return (data.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

@end
