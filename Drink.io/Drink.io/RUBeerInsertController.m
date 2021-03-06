//
//  RUBeersViewController.m
//  Drink.io
//
//  Created by Paul Jones on 11/21/13.
//  Copyright (c) 2013 Principles of Informations and Data Management. All rights reserved.
//

#import "RUBeerInsertController.h"
#import "RUDBManager.h"
#import "RUBeer.h"

@interface RUBeerInsertController ()

@end

@implementation RUBeerInsertController

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
    
    beers = [[RUDBManager getSharedInstance] getBeers];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[beers objectAtIndex:indexPath.row] likedByUser]) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [[beers objectAtIndex:indexPath.row] toggleLike];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [beers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell7";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[beers objectAtIndex:indexPath.row] name];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([[beers objectAtIndex:indexPath.row] likedByUser]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark popup

- (IBAction)plusTapped:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"New Beer"
                                                 message:@"Enter your new beer's information!"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"OK",
                       nil];
    
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[av textFieldAtIndex:1] setSecureTextEntry:NO];
    [[av textFieldAtIndex:0] setPlaceholder:@"Beer name"];
    [[av textFieldAtIndex:1] setPlaceholder:@"Beer manufacturer"];
    [av show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (![[alertView textFieldAtIndex:0].text isEqualToString:@""] &&
        ![[alertView textFieldAtIndex:1].text isEqualToString:@""]) {
        
        RUBeer * beer = [[RUBeer alloc] initWithName:[alertView textFieldAtIndex:0].text
                                 andWithManufacturer:[alertView textFieldAtIndex:1].text];
        
        [beer insertIntoDatabase];
        [beers addObject:beer];
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
