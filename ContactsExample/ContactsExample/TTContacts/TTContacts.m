//
//  TTContacts.m
//  ContactsExample
//
//  Created by TheTiger on 27/08/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

/*
 *  Note: I am an individual developer and just love to code. May be this code has issue or any bug so feel free to fix it accordingly.
 *        This is just a sample code.
 */

#import "TTContacts.h"

@interface TTContacts ()
@property (strong, nonatomic) AddresBookBlock addressBlock;
@end

@implementation TTContacts



//  //
+(TTContacts *)sharedContacts
{
    static TTContacts *contacts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contacts = [[TTContacts alloc] init];
    });
    
    return contacts;
}
//  //






#pragma mark - Get Permission
//  //
-(void)getAddressBookWithCompletionBlock:(AddresBookBlock)block
{
    
    // Getting block
    self.addressBlock = block;
    
    
    // Default Initialization of AddressBook
    ABAddressBookRef addressBook = NULL;
    
    __block BOOL accessGranted = NO;
    
    
    // Checking the method is available or not, This is a method for iOS 6 or later
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // We're on iOS 6
        CFErrorRef errorInCreatingAB = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL, &errorInCreatingAB);
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            
            accessGranted = granted;
            if (accessGranted)
            {
                self.addressBlock (addressBook, nil);
            }
            else
            {
                // Custom Error if app doesn't have users permission to get their AddressBook
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"App doesn't have permission of your AddressBook. Please go to your phone settings>privacy>contacts>Application Name and switch on the permission" forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:@"Permission" code:200 userInfo:details];
                self.addressBlock (NULL, error);
            }
            
            dispatch_semaphore_signal(sema);
            
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        // We're on iOS 5 or older
        addressBook = ABAddressBookCreate();
        accessGranted = YES;
        self.addressBlock (addressBook, nil);
    }
    
}
//  //





#pragma mark - Saving vCard Data
//  //
-(void)saveVCardData:(NSData *)vCardData withCompletionBlock:(void (^)(BOOL, NSError *))block
{
    [self getAddressBookWithCompletionBlock:^(ABAddressBookRef addressBookRef, NSError *error) {
        
        if (!error)
        {
            CFDataRef vCardDataRef = (__bridge CFDataRef)vCardData;
            
            CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(NULL, vCardDataRef);
            for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
                ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
                ABAddressBookAddRecord(addressBookRef, person, NULL);
            }
            
            CFRelease(vCardPeople);
            ABAddressBookSave(addressBookRef, NULL);
            
            block(YES, nil);
        }
        else
        {
            block(NO, error);
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
//  //




#pragma mark - Get All People
//  //
-(void)getAllContactsWithCompletionBlock:(void (^)(NSArray *, NSError *))block
{
    [self getAddressBookWithCompletionBlock:^(ABAddressBookRef addressBookRef, NSError *error) {
        
        if (!error)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            block ((__bridge NSArray *)allPeople, nil);
        }
        else
        {
            block(NO, error);
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
//  //


@end
