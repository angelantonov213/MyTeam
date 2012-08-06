//
//  TableAll.m
//  myteam.14
//
//  Created by Angel Antonov on 06/19/11.
//  Copyright 2011 iHustle. All rights reserved.
//

#import "TableAll.h"


@implementation TableAll
@synthesize moc, tblTable, me;

- (void)showItemsInTable {
    NSError *error;
    // Get all posts
    NSFetchRequest *requestItems = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityItems = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:moc];
    
    // Sort them by PostedOn date
    NSSortDescriptor *sortItems = [[NSSortDescriptor alloc] initWithKey:@"PostedOn" ascending:NO];
    
    [requestItems setEntity:entityItems];
    [requestItems setSortDescriptors:[NSArray arrayWithObject:sortItems]];
    
    [sortItems release];
    
    // Remove old items and fill in the new ones
    [tblItems removeAllObjects];
    [tblItems addObjectsFromArray:(NSArray *)[moc executeFetchRequest:requestItems error:&error]];
    
    // Stop the loading image on the screen
    myteam_15AppDelegate *del = [UIApplication sharedApplication].delegate;
    [del stopLoadingScreen];
    
    // Reload the table with the new items
    [tblTable reloadData];
    
    // Clear the count of unread table items
    [Data sharedData].newTableItems = 0;
}

- (void)getTableItems {
    
    myteam_15AppDelegate *del = [UIApplication sharedApplication].delegate;
    
    // Set which method should be called after the service call has finished
    if([del setMethodAfterService:@selector(showItemsInTable)]) {
        del.callerView = self;
        
        // If there were items in the db already, get only the newer ones from the server
        if ([tblItems count] > 0) {
            Post *post = (Post *)[tblItems objectAtIndex:0];
            
            [CDHelper getTableItemsAfterDate:post.PostedOn];
        }
        else { // else get all
            [CDHelper getTableItemsAfterDate:nil];
        }
        
        // Start the loading image
        [del startLoadingScreenInView:self.view];
    }
}

#pragma -
#pragma Table methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TableItem *itemView = [[TableItem alloc] initWithNibName:@"TableItem" bundle:nil];
	
	itemView.post = (Post *)[tblItems objectAtIndex:indexPath.row];
	
	[self.navigationController pushViewController:itemView animated:YES];
	
	[itemView release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView : (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	return [tblItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 75;
}
- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
	GenericCell *cell = (GenericCell *)[tableView dequeueReusableCellWithIdentifier:@"GenericCell"];
	
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GenericCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (GenericCell *)currentObject;
                break;
            }
        }
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
	Post *post = (Post *)[tblItems objectAtIndex:indexPath.row];
	
    NSString *name;
    NSString *picUrl;
    
    // If the post item was posted by a user - get his/her image
    if(post.PostedByProfile != nil) {
        name = [[NSString alloc] initWithFormat:@"%@ %@", post.PostedByProfile.FirstName, post.PostedByProfile.LastName];
        
        picUrl = [[NSString alloc] initWithFormat:@"%@%@", [post.PostedByProfile.PictureURL stringByReplacingOccurrencesOfString:@"Profiles/" withString:@""] , Image_Size1];
        
        UIImage* image = [Helper getImage:picUrl defaultImage:[NSString stringWithString:Image_DefaultPlayer]];
        [cell.imgProfile setImage:image];
    }
    else if(post.PostedByTeam != nil) { // else if by team, get team's image
            name = [[NSString alloc] initWithFormat:@"%@", post.PostedByTeam.TeamName];
            
            picUrl = [[NSString alloc] initWithFormat:@"%@%@", [post.PostedByTeam.PictureUrl stringByReplacingOccurrencesOfString:@"Teams/" withString:@""] , Image_Size1];
        
            UIImage* image = [Helper getImage:picUrl defaultImage:[NSString stringWithString:Image_DefaultTeam]];
            [cell.imgProfile setImage:image];
        }
    
    
	NSString *status = [[NSString alloc] initWithFormat:@"%@", post.Note];
	cell.lblName.text = name;
	cell.lblText.text = status;
    
    cell.lblText.frame = CGRectMake(cell.lblText.frame.origin.x, cell.lblText.frame.origin.y, 240, cell.lblText.frame.size.height);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:DateOnlyFormat];
	
	NSString *date = [formatter stringFromDate: post.PostedOn];
	[formatter release];
	
	cell.lblDate.text = date;
    
	[name release];
	
	[picUrl release];
    
    [status release];
	
	return cell;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the tblItems array
    tblItems = [[NSMutableArray alloc] init];
    
    // Show the items in the table that are in CoreData
    [self showItemsInTable];
    // Make a call to the server to check for new table items
    [self getTableItems];
	
    // Set the title of the view
	self.title = @"Табло";
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [tblItems release];
    
	[moc release];
	
    [super dealloc];
}


@end
