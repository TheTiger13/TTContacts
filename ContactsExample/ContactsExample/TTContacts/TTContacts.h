//
//  TTContacts.h
//  ContactsExample
//
//  Created by TheTiger on 27/08/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

/*
 *  Note: I am an individual developer and just love to code. May be this code has issue or any bug so feel free to fix it accordingly.
 *        This is just a sample code.
 */

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef void (^AddresBookBlock) (ABAddressBookRef addressBookRef, NSError *error);


@interface TTContacts : NSObject

/*
 * @instance of current class.
 * Every method of this class is block based. Which makes things easy to handling.
 */
+(TTContacts *)sharedContacts;


/*
 * This is method will give the refrence of AddressBook.
 * Will also handle the difference for iOS < 6.0
 * 
 *   ABAddressBookCreateWithOptions(NULL, &error);
 *   ABAddressBookCreate();
 */
-(void)getAddressBookWithCompletionBlock:(AddresBookBlock)block;


/*
 * It is an extra method in this project for saving the "vCard" file into device/simulator.
 * Just convert "vCard" file into NSData and pass it to below method.
 *
 * @Example:
 * NSData *data = [NSData dataWithContentsOfFile:@"vcfFilePath"];
 */
-(void)saveVCardData:(NSData *)vCardData
   withCompletionBlock:(void (^) (BOOL success, NSError *error))block;


/*
 * Method for fetching the contacts from AddressBook.
 * Will give an NSArray of ABRecordRef. You can use them accordingly.
 */
-(void)getAllContactsWithCompletionBlock:(void (^) (NSArray *array, NSError *error))block;


@end
