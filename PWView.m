//
//  PWView.m
//  PWAppKit
//
//  Created by Frank Illenberger on 19/11/2009.
//

#import "PWView.h"
#import "PWViewController.h"

@implementation PWView

@synthesize viewController  = viewController_;

// Reroute the responder chain to include the view controller
- (void)setViewController:(PWViewController*)newController
{
    if(newController != viewController_)
    {
        viewController_ = newController;
        
        if(newController)
        {
            NSResponder* ownNextResponder = self.nextResponder;
            super.nextResponder = newController;
            newController.nextResponder = ownNextResponder;
        }
    }
}

- (void)setNextResponder:(NSResponder*)newNextResponder
{
    if(viewController_)
        viewController_.nextResponder = newNextResponder;
    else
        super.nextResponder = newNextResponder;
}

@end
