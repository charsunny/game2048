//
//  SXSettingViewController.m
//  game2048
//
//  Created by Sun Xi on 3/21/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "SXSettingViewController.h"
#import "SXThemeViewController.h"

@interface SXSettingViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) BOOL showMode;

@property (nonatomic) BOOL showDifficult;

@property (weak, nonatomic) IBOutlet UIPickerView *difficultPicker;

@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;

@property (nonatomic, strong) NSArray* difficultArray;

@property (nonatomic, strong) NSArray* modeArray;

@end

@implementation SXSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _difficultArray = @[@"简单",@"适中",@"困难",@"自虐",@"无聊"];
    _modeArray = @[@"经典模式",@"无限模式",@"闯关模式"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SXThemeViewController class]] ) {
        SXThemeViewController* controller = segue.destinationViewController;
        
        controller.themes = _themes;
        
        controller.currectTheme = [[NSUserDefaults standardUserDefaults] valueForKey:@"theme"];
        
        controller.sender = sender;
        
    }
}

#pragma mark -- tableview delegates 

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        NSNumber* currentTheme = [[NSUserDefaults standardUserDefaults] valueForKey:@"theme"];
        if (!currentTheme) {
            currentTheme = @0;
            [[NSUserDefaults standardUserDefaults] setObject:currentTheme forKey:@"theme"];
        }
        [cell.detailTextLabel setText:_themes[[currentTheme intValue]][@"name"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2 ) {
        return _showDifficult?163:0;
    }
    if (indexPath.section == 0 && indexPath.row == 4) {
        return _showMode?163:0;
    }
    return [tableView rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 1 && indexPath.section == 0) {
        [tableView beginUpdates];
        _showDifficult = !_showDifficult;
        if (_showDifficult) {
            _showMode = NO;
        }
        [tableView reloadData];
        [tableView endUpdates];
    }
    
    if (indexPath.row == 3 && indexPath.section == 0) {
        [tableView beginUpdates];
        _showMode = !_showMode;
        if (_showMode) {
             _showDifficult = NO;
        }
        [tableView reloadData];
        [tableView endUpdates];
    }
}

#pragma mark -- pickview delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:_modePicker]) {
        return _modeArray.count;
    }
    return _difficultArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:_modePicker]) {
        return _modeArray[row];
    }
    return _difficultArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:_modePicker]) {
        NSString* mode = _modeArray[row];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        [cell.detailTextLabel setText:mode];
    } else {
        NSString* difficult = _difficultArray[row];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell.detailTextLabel setText:difficult];
    }
}

@end
