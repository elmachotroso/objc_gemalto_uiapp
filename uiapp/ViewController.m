//
//  ViewController.m
//  uiapp
//
//  Created by Andrei on 24/5/19.
//  Copyright © 2019 Andrei Victor. All rights reserved.
//

#import "ViewController.h"
#import "MovieDbKit/MovieDbKit.h"

@interface ViewController()
{
}
@property (nonatomic, retain) UIActivityIndicatorView * spinner;

@end

@implementation ViewController

@synthesize spinner;
@synthesize cachedMovies;
@synthesize lastRetrieval;


/// Callbacks
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *now = [NSDate date];
    if(self.lastRetrieval == nil)
    {
        lastRetrieval = now;
    }
    NSTimeInterval timeDiff = [now timeIntervalSinceDate:self.lastRetrieval];
    int daysDiff = timeDiff / 86400;
    
    if(self.cachedMovies == nil || (self.cachedMovies != nil && daysDiff > 0))
    {
        NSLog(@"Days Diff Last Retrieved: %d", daysDiff);
        [self showBusy:YES];
        self.cachedMovies = [MovieDbKit retrieveTop10Movies:2017 :2018];
        self.lastRetrieval = [NSDate date];
        
        // TODO: make asynchronous callback version and call these
        [self showBusy:NO];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.cachedMovies != nil)
    {
        return MIN([self.cachedMovies count], 10);
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Top10TableCell" forIndexPath:indexPath];
    
    // config the cell...
    id movieObject = self.cachedMovies[indexPath.row];
    cell.textLabel.text = movieObject[@"title"];
    
    return cell;
}

/// Private Methods
- (void) showBusy: (BOOL) enabled
{
    if(enabled == YES)
    {
        NSLog(@"Show Spinner");
        if(spinner == nil)
        {
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        if(spinner != nil)
        {
            [spinner setBounds:[self.view bounds]];
            [spinner setBackgroundColor:UIColor.blackColor];
            [spinner setUserInteractionEnabled:YES];
            [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [spinner startAnimating];
            [self.view addSubview:spinner];
        }
    }
    else
    {
        NSLog(@"Hide Spinner");
        if(spinner != nil)
        {
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            //[spinner release];
            spinner = nil;
        }
    }
}

@end
