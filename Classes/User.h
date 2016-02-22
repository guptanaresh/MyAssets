//
//  AppSettings.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>


@interface User : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Attributes.
    NSInteger pk;
    NSInteger serverpk;
    NSString *userName;
    NSString *password;
    NSString *udid;
    NSInteger service;
}

@property (assign, nonatomic) NSInteger pk;
@property (assign, nonatomic) NSInteger serverpk;
@property (assign, nonatomic) NSString *userName;
@property (assign, nonatomic) NSString *password;
@property (assign, nonatomic) NSString *udid;
@property (assign, nonatomic) NSInteger service;

+ (void)finalizeStatements;
- (id)initWithDB:(sqlite3 *)db;
- (void)toDB;
- (void)fromDB;
-(void)insertNew;
-(void)updateService;
-(void)uploadService;


@end
