//
//  PWView.h
//  PWAppKit
//
//  Created by Frank Illenberger on 19/11/2009.
//

@class PWViewController;

@interface PWView : NSView

@property (nonatomic, readwrite, weak)   IBOutlet PWViewController* viewController;

@end
