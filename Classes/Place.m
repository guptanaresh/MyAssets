//
//  AssetBox.m
//  MyAssets
//
//  Created by naresh gupta on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Place.h"
#import "Constants.h"
#import "Reachability.h";

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *retrieve_statement = nil;
static sqlite3_stmt *retrieve_all_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;



@implementation Place

@synthesize pk;
// The remaining attributes are copied rather than retained because they are value objects.
@synthesize name;
@synthesize parentID, serverpk;

// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
+ (NSInteger)insertNewPlaceIntoDatabase:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO place (name) VALUES('')";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
	//[Score finalizeStatements];
    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        int pkid= sqlite3_last_insert_rowid(database);
		
		return pkid;
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    return -1;
}



+ (NSMutableArray *)retrieveAllPlaces:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_statement == nil) {
		//static char *sql = "SELECT * FROM asset ORDER BY `name`";
		static char *sql = "SELECT * FROM place ORDER BY `name`";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    NSMutableArray *catArray = [[NSMutableArray alloc] init];
	
	// We "step" through the results - once for each row.
	while (sqlite3_step(retrieve_all_statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int pk = sqlite3_column_int(retrieve_all_statement, 0);
		// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
		// autorelease is slightly more expensive than release. This design choice has nothing to do with
		// actual memory management - at the end of this block of code, all the book objects allocated
		// here will be in memory regardless of whether we use autorelease or release, because they are
		// retained by the books array.
		Place *cat = [[Place alloc] initWithPrimaryKey:pk database:database];
		[catArray addObject:cat];
		[cat release];
	}
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_statement);
    return catArray;
}


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (retrieve_statement) sqlite3_finalize(retrieve_statement);
    if (retrieve_all_statement) sqlite3_finalize(retrieve_all_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (dehydrate_statement) sqlite3_finalize(dehydrate_statement);
}

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)prim database:(sqlite3 *)db {
    if (self = [super init]) {
        pk = prim;
        database = db;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)deleteFromDatabase {
	// Compile the delete statement if needed.
	if (delete_statement == nil) {
		const char *sql = "DELETE FROM place WHERE pk=?";
		if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the primary key variable.
	sqlite3_bind_int(delete_statement, 1, pk);
	// Execute the query.
	int success = sqlite3_step(delete_statement);
	// Reset the statement for future use.
	sqlite3_reset(delete_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
	}
	
	return success;
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
    // Check if action is necessary.
    // Compile the hydration statement, if needed.
    if (hydrate_statement == nil) {
        const char *sql = "SELECT * FROM place WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement, 1, pk);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        self.parentID = (NSInteger)sqlite3_column_int(hydrate_statement, 1);
        char *str = (char *)sqlite3_column_text(hydrate_statement, 2);
        self.name = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.serverpk = (NSInteger)sqlite3_column_int(hydrate_statement, 3);
	} else {
        // The query did not return 
        self.name = @"";
    }
	// Reset the query for the next use.
	sqlite3_reset(hydrate_statement);
	
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
	// Write any changes to the database.
	// First, if needed, compile the dehydrate query.
	if (dehydrate_statement == nil) {
		const char *sql = "UPDATE place SET parentID=?, name=?, serverpk=? WHERE pk=?";
		if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the query variables.
	sqlite3_bind_int(dehydrate_statement, 1, parentID);
	sqlite3_bind_text(dehydrate_statement, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 3, serverpk);
	sqlite3_bind_int(dehydrate_statement, 4, pk);
	
	// Execute the query.
	int success = sqlite3_step(dehydrate_statement);
	// Reset the query for the next use.
	sqlite3_reset(dehydrate_statement);
	// Handle errors.
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
	}
}

- (BOOL)isEqual:(id)anObject{
	Place *crs=(Place *)anObject;
	if(crs != nil && crs.pk == self.pk)
		return TRUE;
	else
		return FALSE;
}


+(BOOL)uploadAllPlaces:(sqlite3 *)database forUser:(User *)aUser
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload because there is no internet connection available."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		NSMutableArray *placeList = [Place retrieveAllPlaces:database];
		NSURL *url = [NSURL URLWithString:@"http://www.jajsoftware.com/myassets/places_upload.php"]; 
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		[request setHTTPMethod:@"POST"];
		
		NSMutableString *post = [NSMutableString stringWithFormat:@"userID=%i", aUser.serverpk];
		NSInteger count=[placeList count];
		for(int i=0; i <count; i++){
			Place	*pl = [placeList objectAtIndex:i];
			[post appendFormat:@"&pk[%i]=%i",i,pl.pk];
			[post appendFormat:@"&parentID[%i]=%i",i,pl.parentID];
			[post appendFormat:@"&name[%i]=%@",i,pl.name];
		}
		
		//		NSLog(post);
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];	
		
		NSError *error;
		NSData *searchData;
		NSHTTPURLResponse *response;
		
		//==== Synchronous call to upload
		searchData = [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!searchData) {
			NSLog([error description]);
			[error release];
			return 0;
		} else {
			NSString *str = [[NSString alloc] initWithData:searchData encoding:NSASCIIStringEncoding];
			NSLog(str);
			return [str intValue];
		}
	}
	return 0;
}	


@end

