//
//  myteam_15AppDelegate.h
//  myteam.15
//
//  Created by Angel Antonov on 1/29/11.
//  Copyright 2011 iHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Helper.h"
#import "Data.h"
#import "Main.h"

@interface myteam_15AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    NSOperationQueue *queue;
    NSMutableArray *imagesForLoading;
    NSString *sessionId;
    SEL methodAfterService;
    NSObject *callerView;
    BOOL setMeToTeam;
    NSString *myID;
    
    UIView *load;
    UIImageView *_imgBall;
    BOOL stopAnimation;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableArray *imagesForLoading;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, retain) NSObject *callerView;
@property BOOL setMeToTeam;
@property (nonatomic, retain) NSString *myID;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;



- (void)downloadImage:(NSString *)url name:(NSString *)imageName filePath:(NSString *)fullFilePath;

- (BOOL)setMethodAfterService:(SEL) method;
- (void)performSelectorForMethodAfterService;

- (void)startAnimation;
- (void)stopAnimation;
- (void)startLoadingScreenInView:(UIView *)holder;
- (void)stopLoadingScreen;

@end

