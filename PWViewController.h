//
//  PWViewController.h
//  PWAppKit
//
//  Created by Frank Illenberger on 03.03.10.
//

// Subclasses should implement strong properties for IBOutlets of top-level objects
// and weak properties for all other IBOutlets.

@interface PWViewController : NSResponder

- (id)initWithNibName:(NSString*)nibNameOrNil       // If nil, view must be set directly or loadView overridden
               bundle:(NSBundle*)nibBundleOrNil;    // If nil, the main bundle is used

// Should be called when the view controller is not needed any more. 
// Default implementation does nothing. Subclasses should remove their observers here or 
// cut their retain cycles.
- (void)dispose;

// Can be overridden by subclasses.
// Default implementation loads the nib with the specified name from the specified bundle.
- (void)loadView;

@property (nonatomic, readonly,  copy)              NSString*   nibName;            // can be overridden by subclasses
@property (nonatomic, readonly,  copy)              NSBundle*   nibBundle;          // can be overridden by subclasses
@property (nonatomic, readwrite, strong) IBOutlet   NSView*     view;               // If accessed for the first time, loadView is called
@property (nonatomic, readonly,  strong)            NSView*     directView;         // Does not load the view
@property (nonatomic, readwrite, strong)            id          representedObject;  // holds custom object

#ifndef NDEBUG
@property (nonatomic, readonly)                     BOOL        isDisposed;         // Gets set by -dispose, use via PWAssertNotDisposed
+ (NSInteger) livingInstancesCount;
+ (void) dumpLivingInstances;       // write living view controller instances to the console
+ (void) resetLivingInstances;
#endif

@end

#define PWAssertNotDisposed NSAssert (!self.isDisposed, @"illegal use after dispose")