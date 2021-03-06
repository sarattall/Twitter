//
//  TweetsViewController.m
//  Twitter
//
//  Created by Sarat Tallamraju on 2/21/15.
//  Copyright (c) 2015 Sarat Tallamraju. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetDetailViewController.h"
#import "ComposeViewController.h"
#import "ProfileViewController.h"

@interface TweetsViewController () <UITableViewDelegate, UITableViewDataSource, TweetCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

// @property (nonatomic, assign) BOOL shouldDisplayMentions;


@end

@implementation TweetsViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.mode == nil) {
        self.mode = @"Timeline";
    }
    
    self.title = @"Home";
    UIBarButtonItem *hamburgerBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Ham"
                                                                               style: UIBarButtonItemStylePlain
                                                                              target: self
                                                                              action: @selector(onHamburger)];
    
    self.navigationItem.leftBarButtonItem = hamburgerBarButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"New"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onNewButton)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName: @"TweetCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier: @"TweetCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserverForName: @"Timeline" object:nil queue: [NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.mode = @"Timeline";
        [self onRefresh];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName: @"Mentions" object:nil queue: [NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.mode = @"Mentions";
        [self onRefresh];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName: @"Profile" object:nil queue: [NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self onProfileButtonClicked];
    }];
    
    
    [self onRefresh];
}

- (void) onRefresh {
    
    if ([self.mode isEqualToString: @"Mentions"]) {
        [[TwitterClient sharedInstance] mentionsWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            NSLog(@"Got mentions tweets");
            self.tweets = tweets;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }];
    } else if ([self.mode isEqualToString: @"Profile"]) {
        [[TwitterClient sharedInstance] userTimelineWithParams:self.timelineParams completion:^(NSArray *tweets, NSError *error) {
            NSLog(@"Got user timeline tweets with params: %@", self.timelineParams);
            self.tweets = tweets;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }];
    } else {
        [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            NSLog(@"Got home timeline tweets");
            self.tweets = tweets;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }];
    }
}


- (void) onProfileButtonClicked {
    ProfileViewController *vc = [[ProfileViewController alloc] init];
    vc.user = [User currentUser];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onThumbnailClickedForTweetCell:(TweetCell *)tweetCell {
    NSLog(@"thumbnail clicked");
    ProfileViewController *vc = [[ProfileViewController alloc] init];
    vc.user = tweetCell.tweet.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onReplyButton: (UIButton *)replyButton forTweetCell: (TweetCell *) tweetCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: tweetCell];
    Tweet *tweet = self.tweets[indexPath.row];
    
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.tweet = tweet;
    vc.shouldActivateReplyUI = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onRetweetButton: (UIButton *)retweetButton forTweetCell: (TweetCell *) tweetCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: tweetCell];
    Tweet *tweet = self.tweets[indexPath.row];
    [[TwitterClient sharedInstance] retweetTweet: tweet];
    [retweetButton setImage: [UIImage imageNamed: @"retweet_on"] forState: UIControlStateNormal];
}

- (void) onFavoriteButton: (UIButton *)favoriteButton forTweetCell: (TweetCell *) tweetCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: tweetCell];
    Tweet *tweet = self.tweets[indexPath.row];
    [[TwitterClient sharedInstance] favoriteTweet: tweet];
    [favoriteButton setImage: [UIImage imageNamed: @"favorite_on"] forState: UIControlStateNormal];
}

#pragma mark Table Listeners

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    // [cell setTweet: tweet];
    cell.tweet = tweet;
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row %ld in section %ld", (long)indexPath.row, (long)indexPath.section);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

// - (void) showTweetDetailWithReplyEnabled

#pragma mark Nav Buttons

- (void) onHamburger {
    NSLog(@"onHamburger");
    [[NSNotificationCenter defaultCenter] postNotificationName: @"Hamburger" object: nil];
}

- (void) onNewButton {
    NSLog(@"New button clicked");
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: vc];
    nvc.navigationBar.translucent = NO;
    
    [self presentViewController: nvc animated:YES completion:nil];
}

- (void) onSignOut {
    NSLog(@"Sign out clicked");
    [[User currentUser] logout];
}

@end
