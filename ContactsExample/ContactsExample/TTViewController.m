//
//  TTViewController.m
//  ContactsExample
//
//  Created by TheTiger on 27/08/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

#import "TTViewController.h"
#import "TTContacts.h"

@interface TTViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *contacts;
@end

@implementation TTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.title = @"Processing...";
    
    
    // Getting AddressBook Refrence
    [[TTContacts sharedContacts] getAddressBookWithCompletionBlock:^(ABAddressBookRef addressBookRef, NSError *error) {
        
        if (error){
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.title = @"Error";
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            });
            
        }
        else {
            
            [[TTContacts sharedContacts] getAllContactsWithCompletionBlock:^(NSArray *array, NSError *error) {
                
                self.contacts = array;
                self.title = [NSString stringWithFormat:@"Total Contacts: %ld", [array count]];
                
                if ([self.contacts count] > 0) {
                    
                    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
                    self.tableView.delegate = self;
                    self.tableView.dataSource = self;
                    [self.view addSubview:self.tableView];
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"There is no contact." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasources & Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    ABRecordRef personRef   = (__bridge ABRecordRef)[self.contacts objectAtIndex:indexPath.row];
    NSString *compositeName = (__bridge NSString *)(ABRecordCopyCompositeName(personRef));
    compositeName = [compositeName stringByReplacingOccurrencesOfString:@" " withString:@""];
    cell.textLabel.text = compositeName;
    
    return cell;
}

@end
