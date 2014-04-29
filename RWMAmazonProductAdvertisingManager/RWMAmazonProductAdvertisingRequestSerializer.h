//
//  RWMAmazonProductAdvertisingRequestSerializer.h
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

#import "AFURLRequestSerialization.h"

extern NSString * const RWMAmazonProductAdvertisingStandardRegion;

@interface RWMAmazonProductAdvertisingRequestSerializer : AFHTTPRequestSerializer
/**
 Whether to connect over HTTPS. `YES` by default.
 */
@property (nonatomic, assign) BOOL useSSL;

/**
 The AWS region for the client. `RWMAmazonProductAdvertisingStandardRegion` by default. Must not be `nil`. See "AWS Regions" for defined constant values.
 */
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *formatPath;

/**
 A readonly endpoint URL created for the specified bucket, region, and TLS preference. `AFAmazonS3Manager` uses this as a `baseURL` unless one is manually specified.
 */
@property (readonly, nonatomic, copy) NSURL *endpointURL;

/**
 Sets the access key ID and secret, used to generate authorization headers.
 
 @param accessKey The Amazon Access Key ID.
 @param secret The Amazon Secret.
 
 @discussion These values can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
 */
- (void)setAccessKeyID:(NSString *)accessKey
                secret:(NSString *)secret;

@end
