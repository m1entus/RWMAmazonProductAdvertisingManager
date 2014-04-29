//
//  RWMAmazonProductAdvertisingRequestSerializer.m
//  AmazonIBNS
//
//  Created by Michał Zaborowski on 25.03.2014.
//  Copyright (c) 2014 Railwaymen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "RWMAmazonProductAdvertisingRequestSerializer.h"
#import "RWMAmazonProductAdvertisingManager.h"
#import <CommonCrypto/CommonCrypto.h>

NSString * const RWMAmazonProductAdvertisingStandardRegion = @"webservices.amazon.com";
NSString * const RWMAmazonProductAdvertisingAWSAccessKey = @"AWSAccessKeyId";
NSString * const RWMAmazonProductAdvertisingTimestampKey = @"Timestamp";
NSString * const RWMAmazonProductAdvertisingSignatureKey = @"Signature";
NSString * const RWMAmazonProductAdvertisingVersionKey = @"Version";
NSString * const RWMAmazonProductAdvertisingCurrentVersion = @"2011-08-01";

NSData * RWMHMACSHA256EncodedDataFromStringWithKey(NSString *string, NSString *key) {
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
    CCHmacContext context;
    const char *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    CCHmacInit(&context, kCCHmacAlgSHA256, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    NSUInteger digestLength = CC_SHA256_DIGEST_LENGTH;
    
    CCHmacFinal(&context, digestRaw);
    
    return [NSData dataWithBytes:digestRaw length:digestLength];
}

NSString * RWMISO8601FormatStringFromDate(NSDate *date) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    return [dateFormatter stringFromDate:date];
}

NSString * RWMBase64EncodedStringFromData(NSData *data) {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    return [data base64EncodedStringWithOptions:0];
#else
    return [data base64Encoding];
#endif
    
}

@interface RWMAmazonProductAdvertisingRequestSerializer ()
@property (readwrite, nonatomic, copy) NSString *accessKey;
@property (readwrite, nonatomic, copy) NSString *secret;
@end

@implementation RWMAmazonProductAdvertisingRequestSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.region = RWMAmazonProductAdvertisingStandardRegion;
    self.useSSL = YES;
    self.formatPath = @"/onca/xml";
    
    return self;
}

- (void)setAccessKeyID:(NSString *)accessKey
                secret:(NSString *)secret
{
    NSParameterAssert(accessKey);
    NSParameterAssert(secret);
    
    self.accessKey = accessKey;
    self.secret = secret;
}

- (NSURL *)endpointURL {
    NSString *URLString = nil;
    NSString *scheme = self.useSSL ? @"https" : @"http";
    URLString = [NSString stringWithFormat:@"%@://%@%@", scheme, self.region,self.formatPath];
    
    return [NSURL URLWithString:URLString];
}

#pragma mark - AFHTTPRequestSerializer

//http://docs.aws.amazon.com/AWSECommerceService/latest/DG/rest-signature.html

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(request);
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    if (self.accessKey && self.secret) {
        NSMutableDictionary *mutableParameters = [parameters mutableCopy];
        NSString *timestamp = RWMISO8601FormatStringFromDate([NSDate date]);
        
        if (!mutableParameters[RWMAmazonProductAdvertisingAWSAccessKey]) {
            [mutableParameters setObject:self.accessKey forKey:RWMAmazonProductAdvertisingAWSAccessKey];
        }
        mutableParameters[RWMAmazonProductAdvertisingVersionKey] = RWMAmazonProductAdvertisingCurrentVersion;
        mutableParameters[RWMAmazonProductAdvertisingTimestampKey] = timestamp;
        
        NSMutableArray *canonicalStringArray = [[NSMutableArray alloc] init];
        for (NSString *key in [[mutableParameters allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            id value = [mutableParameters objectForKey:key];
            [canonicalStringArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
        NSString *canonicalString = [canonicalStringArray componentsJoinedByString:@"&"];
        canonicalString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (__bridge CFStringRef)canonicalString,
                                                                                    NULL,
                                                                                    CFSTR(":,"),
                                                                                    kCFStringEncodingUTF8));
        
        NSString *method = [request HTTPMethod];
        
        NSString *signature = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",method,self.region,self.formatPath,canonicalString];
        
        NSData *encodedSignatureData = RWMHMACSHA256EncodedDataFromStringWithKey(signature,self.secret);
        NSString *encodedSignatureString = RWMBase64EncodedStringFromData(encodedSignatureData);
        
        encodedSignatureString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                           (__bridge CFStringRef)encodedSignatureString,
                                                                                           NULL,
                                                                                           CFSTR("+="),
                                                                                           kCFStringEncodingUTF8));
        
        canonicalString = [canonicalString stringByAppendingFormat:@"&%@=%@",RWMAmazonProductAdvertisingSignatureKey,encodedSignatureString];
        
        mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", canonicalString]];
        
    } else {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Access Key and Secret Required", @"RWMAmazonProductAdvertisingManager", nil)};
            *error = [[NSError alloc] initWithDomain:RWMAmazonProductAdvertisingManagerErrorDomain code:NSURLErrorUserAuthenticationRequired userInfo:userInfo];
        }
    }
    
    return mutableRequest;
    
}


@end
