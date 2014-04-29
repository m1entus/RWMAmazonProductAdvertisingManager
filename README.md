# RWMAmazonProductAdvertisingManager

`RWMAmazonProductAdvertisingManager` is an `AFHTTPRequestOperationManager` subclass for interacting with the [ Amazon Product Advertising API](https://affiliate-program.amazon.com/gp/advertising/api/detail/main.html).

## Example Usage

```objective-c
RWMAmazonProductAdvertisingManager *manager = [[RWMAmazonProductAdvertisingManager alloc] initWithAccessKeyID:@"KEY" secret:@"SECRET"];
manager.responseSerializer = [AFHTTPResponseSerializer serializer];

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

[manager enqueueRequestOperationWithMethod:@"GET" parameters:[parameters copy] success:^(id responseObject) {

} failure:^(NSError *error) {

}];
```

## Contact

Michał Zaborowski

- http://github.com/m1entus
- http://twitter.com/iMientus

## License

RWMAmazonProductAdvertisingManager is available under the MIT license. See the LICENSE file for more info.
