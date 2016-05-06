//
// Created by Quentin Lin on 6/05/2016.
// Copyright (c) 2016 Accedo. All rights reserved.
//

#import "RootViewControllerFactory.h"
#import "IIViewDeckController.h"
#import "IISideController.h"
#import "HighScoreViewController.h"


@implementation RootViewControllerFactory
{

}
- (UIViewController *)create
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *centerController = [storyBoard instantiateViewControllerWithIdentifier:@"mainView"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:centerController];

    IISideController *highScoreSideViewController = [IISideController autoConstrainedSideControllerWithViewController:[[HighScoreViewController alloc] initWithNibName:@"HighScoreViewController" bundle:nil]];

    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:navigationController
                                                                                    leftViewController:nil
                                                                                   rightViewController:highScoreSideViewController];
    return deckController;
}

@end