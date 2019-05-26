//
//  ViewController.h
//  uiapp
//
//  Created by Andrei on 24/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray * cachedMovies;
@property (nonatomic, retain) NSDate * lastRetrieval;

@end
