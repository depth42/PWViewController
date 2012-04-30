//
//  PWViewController.m
//  PWAppKit
//
//  Created by Frank Illenberger on 03.03.10.
//

#import "PWViewController.h"
#import "PWView.h"

#ifndef NDEBUG
static NSMapTable* livingInstances;
@interface PWViewController()
- (void) addToLivingInstances;
@end
#endif

@implementation PWViewController

@synthesize nibName             = nibName_;
@synthesize nibBundle           = nibBundle_;
@synthesize directView          = view_;
@synthesize representedObject   = representedObject_;
#ifndef NDEBUG
@synthesize isDisposed          = isDisposed_;
#endif

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    if(self = [super init])
    {
        nibName_   = [nibNameOrNil copy];
        nibBundle_ = nibBundleOrNil;
    #ifndef NDEBUG
        [self addToLivingInstances];
    #endif
    }
    return self;
}

#ifndef NDEBUG
- (id)init
{
    [self addToLivingInstances];
    return [super init];
}
#endif

#ifndef NDEBUG
- (id)initWithCoder:(NSCoder*)decoder
{
    [self addToLivingInstances];
    return [super initWithCoder:decoder];
}
#endif

#ifndef NDEBUG
- (void) awakeFromNib
{
    PWAssertNotDisposed;
    [super awakeFromNib];
}
#endif

#ifndef NDEBUG
- (void) dealloc
{
    // Note: at least in some tests it is indeed possible to get here without prior -dispose.
    NSAssert (isDisposed_, @"PWViewControllers must always be disposed");
    [livingInstances removeObjectForKey:self];
}
#endif

// Overridden by subclasses
- (void)dispose
{
    // Many (if not most) view controllers use -performSelector:withObject:afterDelay: at some point. Make sure none of
    // these requests are pending after -dispose.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // Even though we more and more use block-based observing where the observer is a separate object, it can’t hurt to
    // make sure no old-style observation is left over.
    [[NSNotificationCenter defaultCenter] removeObserver:self];

#ifndef NDEBUG
    isDisposed_ = YES;
    [livingInstances setObject:[NSNumber numberWithBool:YES] forKey:self];
#endif
}

- (void)loadView
{
    PWAssertNotDisposed;

    NSString* name   = self.nibName;    // always call getter in case subclasses override it
    NSBundle* bundle = self.nibBundle;  // always call getter in case subclasses override it
    if(!name)
        [NSException raise:NSInternalInconsistencyException format:@"Please provide a nib name or set the view directly."];
    
    NSNib* nib = [[NSNib alloc] initWithNibNamed:name bundle:bundle];
    if(!nib)
        [NSException raise:NSInternalInconsistencyException format:@"Could not find nib file named '%@' in bundle '%@'.", name, bundle];
    
    NSArray* topLevelObjects;
    if(![nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects])
        [NSException raise:NSInternalInconsistencyException format:@"Error loading nib file named '%@' in bundle '%@'.", name, bundle];
    
    // NSNib adds an extra retain count to all top-level objects for historical reasons.
    // We can release them as we require all top-level objects to be held by strong IBOutlet properties anyway.
    for(id obj in topLevelObjects)
        CFRelease((__bridge CFTypeRef)obj);
}

- (NSView*)view
{
    if(!view_)
    {
        [self loadView];
        if(!view_)
            [NSException raise:NSInternalInconsistencyException format:@"View could not be created. Is the outlet connected?"];
    }
    return view_;
}

- (void)setView:(NSView*)view
{
    PWAssertNotDisposed;

    if(view != view_)
    {
        // Adjust backpointer of PWViews
        if([view_ isKindOfClass:[PWView class]])
            ((PWView*)view_).viewController = nil;
        
        view_ = view;
        
        // Adjust backpointer of PWViews
        if([view_ isKindOfClass:[PWView class]])
            ((PWView*)view_).viewController = self;
    }
}

// We implement the NSEditor informal protocol with stub methods so that PWViewController can be used
// in places where a NSViewController is expected.
- (BOOL)commitEditing
{
    return YES;
}

- (void)discardEditing
{
}

- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo
{
    // - (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void  *)contextInfo
    NSMethodSignature* signature = [delegate methodSignatureForSelector:didCommitSelector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = didCommitSelector;
    invocation.target = delegate;
    id editor = self;
    BOOL didCommit = YES;
    [invocation setArgument:&editor atIndex:2];
    [invocation setArgument:&didCommit atIndex:3];
    [invocation setArgument:&contextInfo atIndex:4];
    [invocation invoke];
}

#ifndef NDEBUG
- (void) addToLivingInstances
{
    if (!livingInstances)
        livingInstances = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaquePersonality
                                                valueOptions:NSPointerFunctionsObjectPersonality];
    [livingInstances setObject:[NSNumber numberWithBool:NO] forKey:self];
}
#endif

#ifndef NDEBUG
+ (NSInteger) livingInstancesCount
{
    return livingInstances.count;
}
#endif

#ifndef NDEBUG
+ (void) dumpLivingInstances
{
    if (livingInstances.count > 0) {
        NSLog (@"Living View Controllers:\n");
        for (PWViewController* iObj in livingInstances) {
            NSLog (@"%@%@\n",
                   [iObj description],
                   [[livingInstances objectForKey:iObj] boolValue] ? @"" : @" not disposed!" );
        }
    }
}
#endif

#ifndef NDEBUG
+ (void) resetLivingInstances
{
    [livingInstances removeAllObjects];
}
#endif

@end
