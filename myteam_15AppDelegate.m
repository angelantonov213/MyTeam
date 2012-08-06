//
//  myteam_15AppDelegate.m
//  myteam.15
//
//  Created by Angel Antonov on 1/29/11.
//  Copyright 2011 iHome. All rights reserved.
//

#import "myteam_15AppDelegate.h"
#import "Main.h"
#import "ImageLoading.h"


@implementation myteam_15AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize queue;
@synthesize imagesForLoading;
@synthesize sessionId;
@synthesize callerView;
@synthesize setMeToTeam;
@synthesize myID;


- (void)downloadImage:(NSString *)url name:(NSString *)imageName filePath:(NSString *)fullFilePath {
    // Check if the image is already being loaded
    if ([imagesForLoading containsObject:fullFilePath]) {
        return;
    }
    
    // Add to the array with images that are currently being loaded
    [imagesForLoading addObject:fullFilePath];
    
    // Use the global queue
    dispatch_queue_t conncurentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Load the image in another thread
    dispatch_async(conncurentQueue, ^{
        if ([imageName rangeOfString:@"Content"].length > 0) {
            return;
        }
        
        //Retrieve data for the image from the URL
        NSData *dataForImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        //Create the image object
        UIImage *image = [[[UIImage alloc] initWithData:dataForImage] autorelease];
        
        //Write the data to a file depending on the file format
        NSData *dataToWrite;
        
        NSRange textRange;
        textRange =[[imageName lowercaseString] rangeOfString:[@".png" lowercaseString]];
        
        if(textRange.location != NSNotFound)
            dataToWrite = [NSData dataWithData:UIImagePNGRepresentation(image)];
        else
            dataToWrite = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
        
        [dataToWrite writeToFile:fullFilePath atomically:YES];
        
        // Remove the object from array with images that are being loaded
        [imagesForLoading removeObject:fullFilePath];
    });
}

- (BOOL)setMethodAfterService:(SEL) method {
    // Chec if there is available network connection
    if([Helper isSomenetworkAvailable]) {
        // Set the method that should be executed when the service call is finished
        methodAfterService = method;
        // Mark that in the last call there was an available connection to the internet
        [Data sharedData].hasConnection = YES;
        [Data sharedData].isUserNotifiedForNoConnection = NO;
        
        // Check if the user is logged in. If not show the login screen
        if (![Data sharedData].isUserLoggedIn && ![Data sharedData].isInLoginView) {
            // login user
            NSArray *viewContrlls=[[self navigationController] viewControllers];
            
            for (UIViewController *vc in viewContrlls) {
                if ([vc class] == [Main class]) {
                    Main *main = (Main *)vc;
                    [main proccesLogin];
                    break;
                }
            }
        }
        
        return YES;
    }
    else { // If no available connection -> notify the user and mark that the user is notified
        [Data sharedData].hasConnection = NO;
        [Data sharedData].isUserLoggedIn = NO;
        if (![Data sharedData].isUserNotifiedForNoConnection) {
            [Helper showAlert:@"В момента нямате връзка с интернет!" andTitle:@":("];
            [Data sharedData].isUserNotifiedForNoConnection = YES;
        }
        
        return NO;
    }
}

- (void)performSelectorForMethodAfterService {
    if (callerView != nil && [callerView respondsToSelector:methodAfterService]) {
        [callerView performSelector:methodAfterService];
    }
}

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
    
    Main *main = (Main *)[navigationController topViewController];
    main.moc = self.managedObjectContext;
	
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    queue = [[NSOperationQueue alloc] init];
    imagesForLoading = [[NSMutableArray alloc] init];
    setMeToTeam = NO;

    stopAnimation = NO;
    
    return YES;
}

-(void)startLoadingScreenInView:(UIView *)holder {
    // Init the view that will containt the loadding ball
    load = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    load.alpha = 0.0;
    load.backgroundColor = [UIColor colorWithRed:0.0 green:0.63 blue:0.0 alpha:0.1];
    
    // Init the image
    _imgBall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ball.png"]];
    _imgBall.frame = CGRectMake(136, 176, 47, 48);
    
    // Add it to the subview
    [load addSubview:_imgBall];
    
    // Add view to the holder view
    [holder addSubview:load];
    
    // Show the view with the loading image
    [UIView beginAnimations:@"showLoad" context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    load.alpha = 1.0;
    [UIView commitAnimations];
    
    stopAnimation = NO;
    
    // Start the loading animation
    [self startAnimation];
    // Show in the status bar some network connection is used
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)stopLoadingScreen {
    // Stop the animation
    [self stopAnimation];
    
    // Remove the loading image
    [_imgBall removeFromSuperview];
    [_imgBall release];
    _imgBall = nil;
    
    // Remove the view that holds the image
    [load removeFromSuperview];
    [load release];
    load = nil;
}

-(void) startAnimation {
    // Define and add the animation to the layer
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 1.0;
    fullRotation.repeatCount = 1;
    fullRotation.delegate = self;
    [_imgBall.layer addAnimation:fullRotation forKey:@"360"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!stopAnimation) {
        // If the animation should go on, repeat the actions to start the animation again
        [_imgBall.layer removeAnimationForKey:@"360"];
        [self startAnimation];
    }
}

// Mark that the animation should stop
-(void) stopAnimation {
    stopAnimation = YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"myteam_15" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"myteam_15.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [navigationController release];
    [window release];
    
    [myID release];
    [super dealloc];
}


@end

