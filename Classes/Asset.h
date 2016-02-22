//
//  AssetBox.h
//  MyAssets
//
//  Created by naresh gupta on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "User.h"


@interface Asset : NSObject {
		// Opaque reference to the underlying database.
		sqlite3 *database;
		// Primary key in the database.
		NSInteger pk;
		// Attributes.
		NSString	*name;
		NSInteger	quantity;
		double		cost;
		NSDate		*acqrDate;
		NSString	*notes;
		NSInteger	catID;
		NSInteger	containerID;
		NSString	*fieldvalue1;
		NSString	*fieldvalue2;
		NSInteger serverpk;
	NSMutableData   *receivedData;
}
	
	// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
	// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
	// corrupting the database.
	@property (assign, nonatomic, readonly) NSInteger pk;
	@property (assign, nonatomic) NSInteger serverpk;
	// The remaining attributes are copied rather than retained because they are value objects.
	@property (copy, nonatomic) NSString *name;
	@property (assign, nonatomic) NSInteger quantity;
	@property (copy, nonatomic) NSDate *acqrDate;
	@property (assign, nonatomic) double cost;
	@property (copy, nonatomic) NSString *notes;
	@property (assign, nonatomic) NSInteger catID;
	@property (assign, nonatomic) NSInteger containerID;
@property (copy, nonatomic) NSString *fieldvalue1;
@property (copy, nonatomic) NSString *fieldvalue2;
	
	// Inserts a new row in the database to be used for a new Score object.
	+ (NSInteger)insertNewAssetIntoDatabase:(sqlite3 *)database;
	// Finalize (delete) all of the SQLite compiled queries.
	+ (void)finalizeStatements;
	+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database;
	+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database byCategory:(NSInteger)cat;
	+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database byContainer:(NSInteger)container;
+(BOOL)uploadAllAssets:(sqlite3 *)database forUser:(User *)aUser;
	+(UIImage *)scaleAndRotateImage:(UIImage *)image;
	
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
