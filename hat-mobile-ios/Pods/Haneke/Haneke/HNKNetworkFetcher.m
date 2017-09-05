//
//  HNKNetworkFetcher.m
//  Haneke
//
//  Created by Hermes Pique on 7/23/14.
//  Copyright (c) 2014 Hermes Pique. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HNKNetworkFetcher.h"

@implementation HNKNetworkFetcher {
    NSURL *_URL;
    BOOL _cancelled;
    NSURLSessionDataTask *_dataTask;
}

- (instancetype)initWithURL:(NSURL*)URL headers:(NSDictionary*)dict update: (void (^)(float completion))percentage
{
    if (self = [super init])
    {
        _URL = URL;
        _progressUpdate = percentage;
        _dict = dict;
    }
    
    return self;
}

- (NSString*)key
{
    return _URL.absoluteString;
}
    
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    _downloadSize=[response expectedContentLength];
    _dataToDownload=[[NSMutableData alloc]init];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [_dataToDownload appendData:data];
    
    if (_progressUpdate) {

        float value = _dataToDownload.length / _downloadSize;
        _progressUpdate(value);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
        if (error)
        {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) return;

            HanekeLog(@"Request %@ failed with error %@", URL.absoluteString, error);
            if (!_failedBlock) return;

            dispatch_async(dispatch_get_main_queue(), ^{
                _failedBlock(error);
            });
            return;
        }

        if (![task.response isKindOfClass:NSHTTPURLResponse.class])
        {
            HanekeLog(@"Request %@ received unknown response %@", URL.absoluteString, response);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if (httpResponse.statusCode != 200 && httpResponse.statusCode != 201)
        {
            NSString *errorDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
            [self failWithLocalizedDescription:errorDescription code:HNKErrorNetworkFetcherInvalidStatusCode block:_failedBlock];
            return;
        }

        const long long expectedContentLength = task.response.expectedContentLength;
        if (expectedContentLength > -1)
        {
            const NSUInteger dataLength = _dataToDownload.length;
            if (dataLength < expectedContentLength)
            {
                NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Request %@ received %ld out of %ld bytes", @""), _URL.absoluteString, (long)dataLength, (long)expectedContentLength];
                [self failWithLocalizedDescription:errorDescription code:HNKErrorNetworkFetcherMissingData block:_failedBlock];
                return;
            }
        }

        UIImage *image = [UIImage imageWithData:_dataToDownload];

        if (!image)
        {
            NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Failed to load image from data at URL %@", @""), _URL];
            [self failWithLocalizedDescription:errorDescription code:HNKErrorNetworkFetcherInvalidData block:_failedBlock];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _successBlock(image);
        });
}
    
- (void)fetchImageWithSuccess:(void (^)(UIImage *image))successBlock failure:(void (^)(NSError *error))failureBlock
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    [defaultConfigObject setHTTPAdditionalHeaders:_dict];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    self.failedBlock = failureBlock;
    self.successBlock = successBlock;
    _cancelled = NO;
    __weak __typeof__(self) weakSelf = self;
    _dataTask = [urlSession dataTaskWithURL:_URL];
    [_dataTask resume];
}

- (void)cancelFetch
{
    [_dataTask cancel];
    _cancelled = YES;
}

- (void)dealloc
{
    [self cancelFetch];
}

#pragma mark Private

- (void)failWithLocalizedDescription:(NSString*)localizedDescription code:(NSInteger)code block:(void (^)(NSError *error))failureBlock;
{
    HanekeLog(@"%@", localizedDescription);
    if (!failureBlock) return;

    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedDescription , NSURLErrorKey : _URL};
    NSError *error = [NSError errorWithDomain:HNKErrorDomain code:code userInfo:userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        failureBlock(error);
    });
}

@end

@implementation HNKNetworkFetcher(Subclassing)

- (NSURLSession*)URLSession
{
    return [NSURLSession sharedSession];
}

@end
