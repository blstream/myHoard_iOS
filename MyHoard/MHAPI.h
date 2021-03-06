//
//  MHAPI.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
typedef enum  {
	MHThumbnailx160 = 1,
	MHThumbnailx300,
    MHThumbnailx340,
    MHThumbnailx500,
} MHThumbnailSize;

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import "MHUserProfile.h"
#import "MHCollection+MHAPIUtilities.h"
#import "MHMedia.h"

typedef void (^MHAPICompletionBlock)(id object, NSError *error);
typedef void (^MHProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

@interface MHAPI : AFHTTPRequestOperationManager

@property(nonatomic, readonly) NSString *userId;
@property(nonatomic, readonly) NSString *userPassword;

+ (instancetype)getInstance;

+ (void)setSharedAPIInstance:(MHAPI *)api;

- (NSString *)serverUrl;

- (BOOL)token;

- (void)saveToken;

- (AFHTTPRequestOperation *)createUser:(NSString *)email
                          withPassword:(NSString *)password
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)accessTokenForUser:(NSString *)email
                                  withPassword:(NSString *)password
                               completionBlock:(MHAPICompletionBlock)completionBlock;

- (void)logout:(MHAPICompletionBlock)completionBlock;

- (BOOL)activeSession;

- (AFHTTPRequestOperation *)updateUser:(NSString *)username
                          withPassword:(NSString *)password
                              andEmail:(NSString *)email
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)deleteUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)refreshTokenForUser:(NSString *)email
                                   withPassword:(NSString *)password
                                completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)createCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)updateCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)updateMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readMedia:(MHMedia *)media
                      completionBlock:(MHAPICompletionBlock)completionBlock
                        progressBlock:(MHProgressBlock)progressBlock;

- (AFHTTPRequestOperation *)deleteMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)createItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)updateItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readItem:(MHItem *)item
                     completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readAllItemsOfCollection:(MHCollection *)collection
                                     completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)deleteItemWithId:(MHItem *)item
                             completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)deleteCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserCollection:(MHCollection *)collection
                               completionBlock:(MHAPICompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)readUserPrivateCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock;

@end
