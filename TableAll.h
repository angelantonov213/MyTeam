//
//  TableAll.h
//  myteam.14
//
//  Created by Angel Antonov on 06/19/11.
//  Copyright 2011 iHustle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "MyProfile.h"
#import "Constants.h"
#import "ServiceCalls.h"
#import "Constants.h"
#import "Post.h"
#import "Helper.h"
#import "Team.h"
#import "Status.h"
#import "TableItem.h"
#import "GenericCell.h"
#import "CDHelper.h"


@interface TableAll : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
	NSManagedObjectContext *moc;
    
    UITableView *tblTable;
    MyProfile *me;
    NSMutableArray *tblItems;
    
    BOOL stopAnimation;
    UIView *load;
    UIImageView *_imgBall;
}

@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) IBOutlet UITableView *tblTable;

@property (nonatomic, retain) MyProfile *me;


-(void)getTableItems;
-(void)showItemsInTable;
@end
