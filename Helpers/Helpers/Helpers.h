//
//  Helpers.h
//  Helpers
//
//  Created by Andrei on 25/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#ifndef Helpers_H
#define Helpers_H

#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

typedef struct
{
    void *data;
    float rating;
} ListEntry_t;

void SortMoviesByRating(ListEntry_t *list, size_t listCount, bool ascending);
    
#ifdef __cplusplus
}
#endif //__cplusplus

#endif //Helpers_H
