//
//  SettingsWatcher.m
//  Card Match
//
//  Created by Quentin Lin on 8/05/2016.
//  Copyright © 2016 Accedo. All rights reserved.
//

#import "SettingsWatcher.h"
#import "NSString+isEmptyOrWhiteSpace.h"

@interface SettingsWatcher ()
@property (nonatomic, strong) NSString *onlineApiEndpoint;
@property BOOL onlineApiEnabled;
- (void)defaultsChanged:(id)defaultsChanged;
@end

@implementation SettingsWatcher
- (instancetype)init {
    self = super.init;
    if (self) {
        NSDictionary *appDefaults = @{
            @"online_api_enabled_preference": @(YES),
            @"online_api_endpoint_preference": @"http://cardmatch-coder9t99.rhcloud.com/highscore"
        };
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        self.onlineApiEnabled  = [defaults  boolForKey:@"online_api_enabled_preference"];
        self.onlineApiEndpoint = [defaults stringForKey:@"online_api_endpoint_preference"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];

        if (self.onlineApiEnabled) {
            _synchroniser = [[HighScoreSynchroniser alloc] initWithHighScoreEndpoint:self.onlineApiEndpoint];
        }
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)defaultsChanged:(id)defaultsChanged {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    BOOL      newOnlineApiEnabled  = [defaults boolForKey:@"online_api_enabled_preference" ];
    NSString* newOnlineApiEndpoint = [defaults stringForKey:@"online_api_endpoint_preference" ];
    BOOL apiEnableChanged   = newOnlineApiEnabled != self.onlineApiEnabled;
    BOOL apiEndpointChanged = [newOnlineApiEndpoint isEqualToString:self.onlineApiEndpoint];
    self.onlineApiEnabled = newOnlineApiEnabled;
    self.onlineApiEndpoint = newOnlineApiEndpoint;

    if (apiEnableChanged || apiEndpointChanged) {
        [self syncHighScore];
    }
}

- (void)syncHighScore
{
    if (!self.onlineApiEnabled || self.onlineApiEndpoint.isEmptyOrWhiteSpace) {
        _synchroniser = nil;
        return;
    }

    if (!self.synchroniser)
    {
        _synchroniser = [[HighScoreSynchroniser alloc] initWithHighScoreEndpoint:self.onlineApiEndpoint];
    }

    [self.synchroniser sync];
}

@end
