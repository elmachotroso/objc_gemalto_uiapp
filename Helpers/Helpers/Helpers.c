//
//  Helpers.c
//  Helpers
//
//  Created by Andrei on 25/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#include "Helpers.h"
#include <stdlib.h>

/// Forward Declarations
static int Comparer_AscendingRating(const void *a, const void *b);
static int Comparer_DescendingRating(const void *a, const void *b);

/// Public API
void SortMoviesByRating(ListEntry_t *list, size_t listCount, bool ascending)
{
    if(list == 0
       || listCount < 2)
    {
        return;
    }
    
    qsort(list, listCount, sizeof(ListEntry_t),
          (ascending == true) ? Comparer_AscendingRating : Comparer_DescendingRating);
}

/// Private functions
static int Comparer_AscendingRating(const void *a, const void *b)
{
    ListEntry_t leftEntry = *((ListEntry_t*) a);
    ListEntry_t rightEntry = *((ListEntry_t*) b);
    float left = leftEntry.rating;
    float right = rightEntry.rating;
    
    if(left > right)
    {
        return 1;
    }
    if(left < right)
    {
        return -1;
    }
    return 0;
}

static int Comparer_DescendingRating(const void *a, const void *b)
{
    ListEntry_t leftEntry = *((ListEntry_t*) a);
    ListEntry_t rightEntry = *((ListEntry_t*) b);
    float left = leftEntry.rating;
    float right = rightEntry.rating;
    
    if(left < right)
    {
        return 1;
    }
    if(left > right)
    {
        return -1;
    }
    return 0;
}
