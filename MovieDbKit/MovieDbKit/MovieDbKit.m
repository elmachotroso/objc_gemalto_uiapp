//
//  MovieDbKit.m
//  MovieDbKit
//
//  Created by Andrei on 25/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieDbKit.h"
#include "Helpers/Helpers.h"

/// Constants
// TODO: change to a more hidden and secure way later
NSString *const tMDBApiDiscover = @"https://api.themoviedb.org/3/discover/movie";
NSString *const tMDBApiKey = @"9dfc8731b59a33c33109e42216f8d665";
NSString *const tMDBReadAccessToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZGZjODczMWI1OWEzM2MzMzEwOWU0MjIxNmY4ZDY2NSIsInN1YiI6IjVjZTgyYWI2MGUwYTI2NTIyYWQxNjQ3MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FAaoIgn5xA0KOw4_YiEwr9TuKmX056kSLtUN4QmYGUI";

@interface MovieDbKit()
@end

@implementation MovieDbKit

/// Public API
+ (NSMutableArray*)retrieveAllMoviesByPage:(int)page
                                          :(int)fromYear
                                          :(int)toYear
                                          :(int*)totalPages
{
    NSLog(@"retrieveAllMoviesByPage called page: %d", page);
    NSMutableArray *listResults = [[NSMutableArray alloc] init];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            tMDBApiKey, @"api_key",
                            @"2017-01-01", @"primary_release_date.gte",
                            @"2018-12-31", @"primary_release_date.lte",
                            @"en", @"with_original_language",
                            @"popularity.desc", @"sort_by",
                            @(page), @"page",
                            nil];
    id result = [MovieDbKit callRESTApi:true :tMDBApiDiscover :params];
    if (result == nil)
    {
        return nil;
    }
    
    result = [MovieDbKit convertFromJSONData:result];
    if(totalPages != nil)
    {
        *totalPages = [(result[@"total_pages"]) intValue];
        NSLog(@"retrieveAllMoviesByPage total Pages: %d", *totalPages);
    }
    id resultsArray = result[@"results"];
    for(id elem in resultsArray)
    {
        NSString *releaseDate = elem[@"release_date"];
        if(releaseDate != nil)
        {
            int year = [MovieDbKit getYearFromStringDate:releaseDate];
            if(year >= fromYear && year <= toYear)
            {
                //NSLog(@"title: %@, release date: %@", elem[@"title"], releaseDate);
                [listResults addObject:elem];
            }
        }
    }
    
    return listResults;
}

+ (NSMutableArray*)retrieveAllMovies: (int)fromYear
                                    : (int)toYear
{
    NSLog(@"retrieveAllMovies called");
    // TODO: Improve by multi-threading / asynchronous
    NSMutableArray *listResults = [[NSMutableArray alloc] init];
    int page = 1;
    int totalPages = 1;
    do
    {
        id result = [MovieDbKit retrieveAllMoviesByPage:page :2017 :2018 :&totalPages];
        if(result != nil)
        {
            [listResults addObjectsFromArray:result];
        }
        page++;
    } while(page <= totalPages);
    
    return listResults;
}

+ (NSMutableArray*)retrieveTop10Movies: (int)fromYear
                                      : (int)toYear
{
    NSLog(@"retrieveTop10Movies called");
    
    // this is the slow version
    // this basically tries to retrieve all movies in 2017-2018 in all pages.
    // Executing this will take a minutes!!! But the requirement of the test is
    // to retrieve all movies in 2017-2018 and then pass to C sorter.
    NSMutableArray *listResults = [self retrieveAllMovies:fromYear :toYear];
    
    // this is faster (intentionally commented)
    // since the REST api used already returns the top rated movies in 2017-2018 sorted
    // by popularity, we only need the first page of 20 results.
//    NSMutableArray *listResults = [self retrieveAllMoviesByPage:1 :2017 :2018 :nil];
    
    if(listResults == nil)
    {
        return nil;
    }
    
    unsigned long resultsCount = [listResults count];
    if(resultsCount == 0)
    {
        return nil;
    }
    
    // Part where results are sorted via C static library function. Totally unnecessary
    // since the REST query is already sorted, but this is a requirement of the test...
    NSMutableArray *topTen = [[NSMutableArray alloc] init];
    ListEntry_t * cArrayOfListEntry = malloc(resultsCount * sizeof(ListEntry_t));
    if( cArrayOfListEntry != 0 )
    {
        int i = 0;
        for(i=0; i<resultsCount; ++i)
        {
            float rating = [(listResults[i][@"popularity"]) floatValue];
            cArrayOfListEntry[i].data = (__bridge void *) listResults[i];
            cArrayOfListEntry[i].rating = rating;
        }
        Helpers_SortMoviesByRating(cArrayOfListEntry, resultsCount, false);
        for(i=0; i<10 && i<resultsCount; ++i)
        {
            [topTen addObject:((__bridge id)cArrayOfListEntry[i].data)];
        }
        
        free(cArrayOfListEntry);
        cArrayOfListEntry = 0;
    }
    
    return topTen;
}

/// Private functions
+ (int) getYearFromStringDate:(NSString *) dateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [df dateFromString: dateString];
    [df setDateFormat:@"yyyy"];
    NSString *yearString = [df stringFromDate:myDate];
    int year = [yearString intValue];
    return year;
}

+ (NSData*) callRESTApi: (BOOL) isPost
                       : (NSString*) apiURL
                       : (NSDictionary *) parameterMap
{
    NSString *parameters = nil;
    for(id key in [parameterMap allKeys])
    {
        if(parameters == nil)
        {
            parameters = [NSString stringWithFormat:@"%@=%@", key, parameterMap[key]];
        }
        else
        {
            parameters = [NSString stringWithFormat:@"%@&%@=%@", parameters, key, parameterMap[key]];
        }
    }
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:apiURL]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0f];
    [request setHTTPMethod: ((isPost) ? @"POST" : @"GET")];
    if(isPost)
    {
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if(err != nil)
    {
        NSLog(@"Error getting %@, error code %@", apiURL, [err localizedFailureReason]);
        return nil;
    }
    else if([response statusCode] != 200)
    {
        NSLog(@"Error getting %@, HTTP status code %ld", apiURL, [response statusCode]);
        return nil;
    }
    
    return responseData;
}

+ (id) convertFromJSONData: (id)data
{
    NSError* error = nil;
    if (data == (id)[NSNull null])
    {
        return [[NSObject alloc] init];
    }
    
    id jsonObject = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    else
    {
        jsonObject = data;
    }
    
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *array = [jsonObject mutableCopy];
        for (int i = (int)array.count-1; i >= 0; --i)
        {
            id a = array[i];
            if (a == (id)[NSNull null])
            {
                [array removeObjectAtIndex:i];
            }
            else
            {
                array[i] = [MovieDbKit convertFromJSONData:a];
            }
        }
        return array;
    }
    else if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *dictionary = [jsonObject mutableCopy];
        for(NSString *key in [dictionary allKeys])
        {
            id d = dictionary[key];
            if (d == (id)[NSNull null])
            {
                dictionary[key] = @"";
            }
            else
            {
                dictionary[key] = [MovieDbKit convertFromJSONData:d];
            }
        }
        return dictionary;
    }
    else
    {
        return jsonObject;
    }
}

@end
