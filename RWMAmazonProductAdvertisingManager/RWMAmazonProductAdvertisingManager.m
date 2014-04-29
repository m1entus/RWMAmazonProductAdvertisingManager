//
//  RWMAmazonProductAdvertisingManager.m
//  RWMAmazonProductAdvertisingManager
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

#import "RWMAmazonProductAdvertisingManager.h"

NSString * const RWMAmazonProductAdvertisingManagerErrorDomain = @"RWMAmazonProductAdvertisingManagerErrorDomain";

@implementation RWMAmazonProductAdvertisingManager
@synthesize baseURL = _amazon_baseURL;

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [RWMAmazonProductAdvertisingRequestSerializer serializer];
    self.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    return self;
}

- (id)initWithAccessKeyID:(NSString *)accessKey
                   secret:(NSString *)secret
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    [self.requestSerializer setAccessKeyID:accessKey secret:secret];
    
    return self;
}

- (NSURL *)baseURL {
    if (!_amazon_baseURL) {
        return self.requestSerializer.endpointURL;
    }
	
    return _amazon_baseURL;
}

- (void)itemLookupOperationWithISBN:(NSString *)ISBN type:(RWMAmazonProductAdvertisingISBN)type
                                  success:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [@{
                                 @"Service" : @"AWSECommerceService",
                                 @"Operation" : @"ItemLookup",
                                 @"ItemId" : ISBN,
                                 @"ResponseGroup" : @"ItemAttributes,Images,EditorialReview",
                                 @"AssociateTag" : @"12345"
                                 } mutableCopy];
    
    if (type == RWMAmazonProductAdvertisingISBN13) {
        [parameters setObject:@"EAN" forKey:@"IdType"];
        [parameters setObject:@"Books" forKey:@"SearchIndex"];
        [parameters setObject:@"All" forKey:@"Condition"];
    }
    
    [self enqueueRequestOperationWithMethod:@"GET" parameters:[parameters copy] success:success failure:failure];
}

- (void)enqueueRequestOperationWithMethod:(NSString *)method
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[self.baseURL absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
	
    [self.operationQueue addOperation:requestOperation];
}

@end
