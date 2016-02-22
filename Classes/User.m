//
//  AppSettings.m
//  GolfMemoir
//
//  Created by naresh gupta on 9/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Constants.h"
#import "Reachability.h"


@implementation User
// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;



@synthesize pk, serverpk, userName, password, udid, service;


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (dehydrate_statement) sqlite3_finalize(dehydrate_statement);
    if (insert_statement) sqlite3_finalize(insert_statement);
	
}

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithDB:(sqlite3 *)db {
    if (self = [super init]) {
        database = db;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
    // Check if action is necessary.
    // Compile the hydration statement, if needed.
    if (hydrate_statement == nil) {
        char *sql = "SELECT * FROM user where pk=0";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    int success =sqlite3_step(hydrate_statement);
	// Reset the query for the next use.
	
    if (success == SQLITE_ROW) {
        self.pk = sqlite3_column_int(hydrate_statement, 0);
        self.serverpk = sqlite3_column_int(hydrate_statement, 1);
        char *str = (char *)sqlite3_column_text(hydrate_statement, 2);
        self.userName = (str) ? [NSString stringWithUTF8String:str] : nil;
        str = (char *)sqlite3_column_text(hydrate_statement, 3);
        self.password = (str) ? [NSString stringWithUTF8String:str] : nil;
        str = (char *)sqlite3_column_text(hydrate_statement, 4);
        self.udid = (str) ? [NSString stringWithUTF8String:str] : nil;
        self.service = sqlite3_column_int(hydrate_statement, 5);
	} else {
        self.pk = 0;
        self.serverpk = 0;
        self.userName = nil;
        self.password =  nil;
        self.udid = nil;
        self.service = 0;
		[self insertNew];
    }
	sqlite3_reset(hydrate_statement);
	
}

-(void)insertNew 
{
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_statement == nil) {
        char *sql = "INSERT INTO user (pk, serverpk) VALUES(?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(insert_statement, 1, pk);
	sqlite3_bind_int(insert_statement, 2, serverpk);
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR)
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
	// Write any changes to the database.
	// First, if needed, compile the dehydrate query.
	if (dehydrate_statement == nil) {
		char *sql = "UPDATE user SET serverpk=?, username=?, password=? , udid=?, service=? where pk=?";
		if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the query variables.
	sqlite3_bind_int(dehydrate_statement, 1, serverpk);
	sqlite3_bind_text(dehydrate_statement, 2, [userName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 3, [password UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 4, [udid UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 5, self.service);
	sqlite3_bind_int(dehydrate_statement, 6, pk);
	// Execute the query.
	int success = sqlite3_step(dehydrate_statement);
	// Reset the query for the next use.
	sqlite3_reset(dehydrate_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
}

-(void)updateService
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't download info from internet."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else {
		NSString *str=[NSString stringWithFormat:@"http://www.jajsoftware.com/myassets/unlock_download.php?udid=%@", [[UIDevice currentDevice] uniqueIdentifier]];
		//NSString *str=[NSString stringWithFormat:@"http://www.golfmemoir.com/unlock_download.php?udid=%@%i", [[UIDevice currentDevice] uniqueIdentifier],1];
		
		NSURL *url = [NSURL URLWithString:str]; 
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSError *error;
		NSData *searchData;
		NSURLResponse *response;
		
		//==== Synchronous call to upload
		searchData = [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!searchData) {
			NSLog([error description]);
			[error release];
		} else {
			NSString *str = [[NSString alloc] initWithData:searchData encoding:NSASCIIStringEncoding];
			NSLog(str);
			service = service | [str intValue];
		}
	}
}	

-(void)uploadService
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload to internet."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else {
		NSString *str=[NSString stringWithFormat:@"http://www.jajsoftware.com/myassets/user_updateService.php?udid=%@&service=%i", [[UIDevice currentDevice] uniqueIdentifier], service];
		
		NSURL *url = [NSURL URLWithString:str]; 
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSError *error;
		NSData *searchData;
		NSURLResponse *response;
		
		//==== Synchronous call to upload
		searchData = [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!searchData) {
			NSLog([error description]);
			[error release];
		} 
	}
}	


@end
