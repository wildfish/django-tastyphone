//
//  
//
//  Created by tastyphone on 20/8/2012.
//

#import "RESTConnection.h"

@interface RESTConnection (Private)
- (NSURL *)getUrl:(NSString *)actionUrl;
- (NSMutableURLRequest*)createRequest:(NSURL *)url;
@end


@implementation RESTConnection

@synthesize delegate;

- (id)initWithTargetClass:(Class)theClass {
	if ((self = [super init])) {
		_targetClass = theClass;
		_receivedData = [[NSMutableData alloc] init];
	}
	return self;
}

#pragma mark - GET
- (void)makeGetRequest:(NSString *)destination {
	NSURL *url = [self getUrl:destination];
	NSLog(@"Url [GET]: %@", url);

	NSMutableURLRequest *request = [self createRequest:url];
	[request setHTTPMethod:@"GET"];
	[request addValue:@"application/json" forHTTPHeaderField:@"content-type"];

	_urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - POST
- (void)makePostRequest:(NSDictionary *)formData withDestination:(NSString *)destination
{
	NSURL *url = [self getUrl:destination];
	NSLog(@"Url [POST]: %@", url);

	NSMutableURLRequest *request = [self createRequest:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

	NSError *error;
	NSData *postData = [NSJSONSerialization dataWithJSONObject:formData options:kNilOptions error:&error];
	[request setHTTPBody:postData];

	_urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

#pragma mark - PUT
- (void)makePutRequest:(NSDictionary *)formData withDestination:(NSString *)destination
{
	NSURL *url = [self getUrl:destination];
	NSLog(@"Url [PUT]: %@", url);

	NSMutableURLRequest *request = [self createRequest:url];
	[request setHTTPMethod:@"PUT"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

	NSError *error;
	NSData *putData = [NSJSONSerialization dataWithJSONObject:formData options:kNilOptions error:&error];
	[request setHTTPBody:putData];

	_urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

#pragma mark - DELETE
- (void)makeDeleteRequest:(NSString *)destination {
	NSURL *url = [self getUrl:destination];
	NSLog(@"Url [DELETE]: %@", url);

	NSMutableURLRequest *request = [self createRequest:url];

	[request setHTTPMethod:@"DELETE"];
	[request addValue:@"application/json" forHTTPHeaderField:@"content-type"];

	_urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


#pragma mark - NSUrlConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (self.delegate == nil)
		return;

	[self.delegate connectionError];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_statuscode = [(NSHTTPURLResponse *)response statusCode];
}

// Request complete and connection done loading
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	if (!(self.delegate))
		return;

	NSError *error;
	id obj = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:&error];

	if (_statuscode >= 200 && _statuscode < 300) {
		id<ObjectMapProtocol> objectMap = [[ObjectMapperFactory sharedInstance] getMapperForClass:_targetClass];
		if (self.delegate != nil && objectMap != nil && obj != nil) {
			[self.delegate dataReceived:[objectMap mapObject:obj]];
		} else {
			[self.delegate dataReceived:nil];
		}
	} else {
		if (_statuscode == 401) { // auth required
//			if ([DPSettingsHelper isAuthenticatedUser] == YES)
//				[DPSettingsHelper removeUserDetails];
		} else {
			ApiError *apiError = [[ApiError alloc] init];
			if ([obj isKindOfClass:[NSDictionary class]]) {
				apiError.message = [obj objectForKey:@"error"];
			}
			if (self.delegate != nil)
				[self.delegate apiErrorReceived:apiError];
			[apiError release];
		}
	}

	[_receivedData setLength:0];
}


#pragma mark - private methods

- (NSURL *)getUrl:(NSString *)actionUrl
{
	NSString *rawUri = [[NSString alloc]initWithFormat:@"%@%@", kApiRootUrl, actionUrl];
	NSURL *url = [[[NSURL alloc] initWithString:rawUri] autorelease];
	[rawUri release];
	return url;
}

- (NSMutableURLRequest*)createRequest:(NSURL *)url {
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30] autorelease];

	id<AuthenticationProtocol> auth = [[AuthenticationProvider sharedInstance] getAuthenticator];
	NSDictionary *authHeaders = [auth getAuthenticationHeaders];
	for (NSString *key in [authHeaders allKeys]) {
		[request addValue:[authHeaders objectForKey:key] forHTTPHeaderField:key];
	}
	
//	NSString *token = [DPSettingsHelper getApiKey];
//	if (token)
//		[request addValue:token forHTTPHeaderField:@"api_key"];

	return request;
}

@end
