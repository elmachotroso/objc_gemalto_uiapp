//
//  MovieDbKitTests.m
//  MovieDbKitTests
//
//  Created by Andrei on 25/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "Helpers/Helpers.h"
#include "MovieDbKit/MovieDbKit.h"

@interface MovieDbKitTests : XCTestCase

@end

@implementation MovieDbKitTests

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSortingFromStaticC
{
    ListEntry_t listingEntries[] = {
        { .data = 0, .rating = 2.0f },
        { .data = 0, .rating = 1.0f },
        { .data = 0, .rating = 5.0f },
        { .data = 0, .rating = 4.0f },
        { .data = 0, .rating = 8.0f },
        { .data = 0, .rating = 3.0f },
        { .data = 0, .rating = 9.0f },
        { .data = 0, .rating = 10.0f },
        { .data = 0, .rating = 7.0f },
        { .data = 0, .rating = 6.0f }
    };
    
    int size = sizeof(listingEntries) / sizeof(ListEntry_t);
    
    NSLog(@">>>>> BEFORE SORTING");
    for(int i=0; i<size; ++i)
    {
        NSLog(@"Element %f", listingEntries[i].rating);
    }
    
    Helpers_SortMoviesByRating(listingEntries, size, false);
    NSLog(@">>>>> AFTER SORTING DESCENDING");
    for(int i=0; i<size; ++i)
    {
        NSLog(@"Element %f", listingEntries[i].rating);
    }
    
    Helpers_SortMoviesByRating(listingEntries, size, true);
    NSLog(@">>>>> AFTER SORTING ASCENDING");
    for(int i=0; i<size; ++i)
    {
        NSLog(@"Element %f", listingEntries[i].rating);
    }
    
    XCTAssertEqual(listingEntries[9].rating, 10.0f);
}

- (void)testRetrieveAllMoviesByPage
{
    int totalPages = 1;
    NSMutableArray *results = [MovieDbKit retrieveAllMoviesByPage:1 :2017 :2018 :&totalPages];
    XCTAssertNotNil(results);
}

- (void)testRetrieveAllMovies
{
    NSMutableArray *results = [MovieDbKit retrieveAllMovies:2017 :2018];
    XCTAssertNotNil(results);
}

- (void)testRetrieveTop10
{
    NSMutableArray *results = [MovieDbKit retrieveTop10Movies:2017 :2018];
    unsigned long size = [results count];
    for(unsigned long i=0; i<size; ++i)
    {
        id elem = results[i];
        if(elem != nil)
        {
            NSLog(@"Title: %@\nRelease Date: %@\nRating: %g",
                  elem[@"title"],
                  elem[@"release_date"],
                  [elem[@"vote_average"] floatValue]);
        }
    }
    XCTAssertTrue([results count] <= 10);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
