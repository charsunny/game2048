//
//  SXHistoryTableViewController.m
//  game2048
//
//  Created by Sun Xi on 3/24/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXHistoryTableViewController.h"
#import "SXAppConfig.h"

@interface SXHistoryTableViewController ()

@property (strong, nonatomic) NSMutableArray* historyArray;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *orderTypeButton;

@property (nonatomic) BOOL orderByScore;

@end

@implementation SXHistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _historyArray = [[SXAppConfig sharedAppConfig] history];
     self.clearsSelectionOnViewWillAppear = YES;
     //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _historyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    SXHistoryModel* model = [_historyArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"得分: %ld",(long)model.score]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"时间: %@", model.time]];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        SXHistoryModel* model = _historyArray[indexPath.row];
        [[SXAppConfig sharedAppConfig] removeHistory:model];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)order:(UIBarButtonItem*)sender {
    _orderByScore = !_orderByScore;
    [self.tableView beginUpdates];
    [sender setTitle:_orderByScore?@"分数排序":@"时间排序"];
    [_historyArray sortUsingComparator:^NSComparisonResult(SXHistoryModel* obj1, SXHistoryModel* obj2) {
        if (_orderByScore) {
            return obj1.score < obj2.score;
        }
        return [obj2.time compare:obj1.time];
    }];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

@end
