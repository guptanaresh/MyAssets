//
//  Category.h
//  MyAssets
//
//  Created by naresh gupta on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "User.h";


@interface Place : NSObject {
	// Opaque reference to the underlying database.
	sqlite3 *database;
	// Primary key in the database.
	NSInteger pk;
	// Attributes.
	NSInteger	parentID;
	NSString	*name;
	NSInteger serverpk;
}

// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
// corrupting the database.
@property (assign, nonatomic, readonly) NSInteger pk;
@property (assign, nonatomic) NSInteger serverpk;
@property (assign, nonatomic) NSInteger parentID;
@property (copy, nonatomic) NSString *name;

// Inserts a new row in the database to be used for a new Score object.
+ (NSInteger)insertNewPlaceIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;
+ (NSMutableArray *)retrieveAllPlaces:(sqlite3 *)database;
+(BOOL)uploadAllPlaces:(sqlite3 *)database forUser:(User *)aUser;

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB;
// Flushes all but the primary key and courseName out to the database.
- (void)toDB;
// Remove the Score complete from the database. In memory deletion to follow...
- (BOOL)deleteFromDatabase;

- (BOOL)isEqual:(id)anObject;


@end
