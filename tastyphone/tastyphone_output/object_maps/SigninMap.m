//
//  
//
//  Created by tastyphone on 23/8/2012.
//


#import "SigninMap.h"
#import "NSDate+DateFromString.h"

@interface SigninMap (Private)
- (id)mapInstance:(id)data;
@end
@implementation SigninMap
- (id)mapObject:(id)data {
	if ([data objectForKey:@"objects"] != nil) {
		NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
		for (NSDictionary *a in [data objectForKey:@"objects"]){
			[items addObject:[self mapInstance:a]];
		}

		return items;
	}

 else {
		return [self mapInstance:data];
	}

}

- (id)mapInstance:(id)data {
	Signin *instance = [[[Signin alloc] init] autorelease];
	instance.username = [data objectForKey:@"username"];
	instance.password = [data objectForKey:@"password"];
	instance.resourceUri = [data objectForKey:@"resource_uri"];
	return instance;
}

@end
