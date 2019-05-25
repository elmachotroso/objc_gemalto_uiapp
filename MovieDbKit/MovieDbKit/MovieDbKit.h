//
//  MovieDbKit.h
//  MovieDbKit
//
//  Created by Andrei on 25/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const tMDBApiKey;
FOUNDATION_EXPORT NSString *const tMDBReadAccessToken;

FOUNDATION_EXPORT double MovieDbKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MovieDbKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MovieDbKit/PublicHeader.h>

@interface MovieDbKit : NSObject
{
}

/// Public API
+ (NSMutableArray*)retrieveAllMoviesByPage:(int)page :(int)fromYear :(int)toYear :(int *) totalPages;
+ (NSMutableArray*)retrieveAllMovies:(int)fromYear :(int)toYear;
+ (NSMutableArray*)retrieveTop10Movies:(int)fromYear :(int)toYear;
@end
