//
//  NetworkManager.m
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "NetworkManager.h"
#import "Constants.h"

@implementation NetworkManager
@synthesize httpRequestType;
@synthesize requestUrl;
@synthesize responseData;
@synthesize urlConnection;
@synthesize httpUrlResponse;
@synthesize mNetworkDelegate;


/*!
 * @method cancelNetworkRequest
 * @Function is used to cancel the Network Request.
 * @param none
 * @return void
 */
-(void) cancelNetworkRequest
{
    responseData = nil;
    [self.urlConnection cancel];
    self.urlConnection = nil;
}


/*!
 * @method networkRequest
 * @Function is used to check the network availability and forward the network request.
 * @param requestType: network request type , requestBody: http data to be send to a server,
 * isAsyncReq: option to create sync or asyn request, error: carry the error value
 * @return networkData returns the http response
 */
-(void) networkRequest:(NSInteger)requestType RequestBody:(NSDictionary*)requestBody isRequestAsynchronous:(BOOL)isAsyncReq
{
    reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        [mNetworkDelegate networkErrorHandling: nil responseCode: -1];
       
    } else
    {
        //        Network is Reachable
        [self createHttpRequest:requestBody RequestType:requestType IsRequestAsynchronous:isAsyncReq];
    }
}

#pragma NETWORK REQUEST METHODS

/*!
 * @method createHttpRequest
 * @Function is used to compose the http request.
 * @param requestType: network request type , httpBody: http data to be send to a server,
 * isAsyncReq: option to create sync or asyn request, nwError: carry the error value
 * @return the server response
 */
-(void) createHttpRequest:(NSDictionary*) httpBody RequestType:(NSInteger)requestType IsRequestAsynchronous:(BOOL)isAsyncReq
{
    NSString *httpReqApi = [self getHttpRequestApi:requestType];
    NSString *urlString = [IPS_SERVER_URL stringByAppendingString:httpReqApi];
    NSString *httpMethod = [self getHttpMethod:requestType];
    
    NSURL *url = nil;
    NSMutableURLRequest *urlRequest = nil;
//    NSString *myRequestString = nil;
//    myRequestString = [self createQueryStringForDictKeys:httpBody];
//    myRequestString = [@"json=" stringByAppendingString:myRequestString];
    if ([httpMethod isEqualToString:HTTP_METHOD_GET])
    {
        url = [NSURL URLWithString: urlString];
        urlRequest = [NSMutableURLRequest requestWithURL: url];
    }
    else if ([httpMethod isEqualToString:HTTP_METHOD_POST])
    {
        url = [NSURL URLWithString: urlString];
        urlRequest = [NSMutableURLRequest requestWithURL: url];
        //NSData *paramData = [JSONParser jsonSerializer:httpBody];
        NSData *paramData1 = [@"json=" dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *da = [[NSMutableData alloc]init];
        [da appendData:paramData1];
       // [da appendData:paramData];
        NSMutableData *httpBody = [[NSMutableData alloc] initWithData: da];
        [urlRequest setHTTPBody: httpBody];
        
    }
    [urlRequest setHTTPMethod:httpMethod];

    if (isAsyncReq) {
        [self sendHttpAsynRequest:urlRequest RequestType:requestType];
    }
    
}


/*!
 * @method createQueryStringForDictKeys
 * @Function is used to create query string format from dictionary keys.
 * @param queryDict
 * the error value
 * @return the query format string
 */
- (NSString *) createQueryStringForDictKeys : (NSDictionary *) queryDict
{
    if ([queryDict count] < 1)
    {
        return nil;
    }
    
    NSEnumerator *keyEnum = [queryDict keyEnumerator];
    NSString *keyString = nil;
    
    NSString *queryString = EMPTY_STRING;
    
    while ((keyString = [keyEnum nextObject]))
    {
        NSString *valueString = [queryDict objectForKey: keyString];
        NSArray *objectArr = [valueString componentsSeparatedByString: @","];
        if ([objectArr count] > 0)
        {
            NSEnumerator *keyEnum = [objectArr objectEnumerator];
            NSString *objString = nil;
            
            while ((objString = [keyEnum nextObject]))
            {
                queryString = [queryString stringByAppendingFormat: @"%@:%@&", keyString,objString];
            }
        }
        else
        {
            queryString = [queryString stringByAppendingFormat: @"%@:%@&", keyString,valueString];
        }
    }
    queryString = [queryString substringToIndex: ([queryString length] - 1)];
    return queryString;
}


/*!
 * @method getHttpRequestApi
 * @Function is used to identify the server API based upon network request type.
 * @param requestType: network request type
 * @return httpReqApi returns the server API name
 */
- (NSString *)getHttpRequestApi:(NSInteger) requestType
{
    NSString *httpReqApi = nil;
    switch(requestType)
    {

        case 9001:
            httpReqApi = @"/mobilePOCData.csv";
            
            //httpReqApi = @"IpsDemo/vodafone-test/serverdatechanged.csv"
            break;
    }
    
    return httpReqApi;
}

/*!
 * @method getHttpMethod
 * @Function is used to identify the HTTP method based upon network request type.
 * @param requestType: network request type
 * @return httpMethodName returns the http method type
 */
- (NSString *)getHttpMethod:(NSInteger) requestType {
    NSString *httpMethodName = nil;
    switch(requestType)
    {
            case 9001:
            httpMethodName = @"GET";
            break;
    }
    return httpMethodName;
}


/*!
 * @method sendHttpAsynRequest
 * @Function is used to send the asynchronous http request.
 * @param urlRequest: composed http request object requestType: network request type, nwError: carry
 * the error value
 */
-(void) sendHttpAsynRequest:(NSURLRequest*) urlRequest RequestType:(NSInteger) requestType
{
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    self.httpRequestType = requestType;
    self.requestUrl = urlRequest;
}




/**********************************NETWORK RESPONSE METHODS**************************************/

/*!
 * @method connection
 * @Function is used to sent as a connection to construct url response.
 * @param connection:connection sending the message response: URL response for the connection's request
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@" didReceiveResponse ***** ");
    self.httpUrlResponse = (NSHTTPURLResponse*)response;
    self.responseData = [[NSMutableData alloc]init];
    [self.responseData setLength: 0];
    NSDictionary *dict = self.httpUrlResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
}

/*!
 * @method connection
 * @Function is used to retrieve the loaded data.
 * @param connection:connection sending the message data: newly available data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData: data];
    self.receivedBytes += data.length;
}

/*!
 * @method connection
 * @Function is called when error occurs.
 * @param connection:connection sending the message error: newly available data
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", [error localizedDescription]);
   }


- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse
{
    return inRequest;
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSInteger requestType = self.httpRequestType;
    NSData* data = self.responseData;
    NSString *responseString;
    if ([data length] > 0)
    {
        responseString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        switch (requestType) {
            case 9001:
            {
                [mNetworkDelegate processResponse:(id)responseString RequestType:requestType];
            }
                break;
                
            default:
                break;
        }
    }
    
}



@end
