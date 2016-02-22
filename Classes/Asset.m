//
//  AssetBox.m
//  MyAssets
//
//  Created by naresh gupta on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Asset.h"
#import "Constants.h"
#import "Reachability.h";
#import "AddAssetViewController.h";

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *retrieve_statement = nil;
static sqlite3_stmt *retrieve_all_statement = nil;
static sqlite3_stmt *retrieve_all_cat_statement = nil;
static sqlite3_stmt *retrieve_all_loc_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;



@implementation Asset

@synthesize pk;
// The remaining attributes are copied rather than retained because they are value objects.
@synthesize name;
@synthesize quantity;
@synthesize acqrDate;
@synthesize cost;
@synthesize notes;
@synthesize catID;
@synthesize containerID, fieldvalue1, fieldvalue2, serverpk;

// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
+ (NSInteger)insertNewAssetIntoDatabase:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO asset (name,quantity,cost,acqrDate,notes,catID,containerID,fieldvalue1,fieldvalue2, serverpk) VALUES('',0,0,?,'',0,0,'','',0)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_double(insert_statement, 1, [[NSDate date] timeIntervalSince1970]);

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



+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_statement == nil) {
		//static char *sql = "SELECT * FROM asset ORDER BY `name`";
		static char *sql = "SELECT * FROM asset ORDER BY `name`";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
	
	// We "step" through the results - once for each row.
	while (sqlite3_step(retrieve_all_statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int pk = sqlite3_column_int(retrieve_all_statement, 0);
		// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
		// autorelease is slightly more expensive than release. This design choice has nothing to do with
		// actual memory management - at the end of this block of code, all the book objects allocated
		// here will be in memory regardless of whether we use autorelease or release, because they are
		// retained by the books array.
		Asset *asset = [[Asset alloc] initWithPrimaryKey:pk database:database];
		[asset fromDB];
		[assetArray addObject:asset];
		[asset release];
	}
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_statement);
    return assetArray;
}

+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database byCategory:(NSInteger)cat
{
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_cat_statement == nil) {
		//static char *sql = "SELECT * FROM asset ORDER BY `name`";
		static char *sql = "SELECT * FROM asset where catID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_cat_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(retrieve_all_cat_statement, 1, cat);

    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
	
	// We "step" through the results - once for each row.
	while (sqlite3_step(retrieve_all_cat_statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int pk = sqlite3_column_int(retrieve_all_cat_statement, 0);
		// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
		// autorelease is slightly more expensive than release. This design choice has nothing to do with
		// actual memory management - at the end of this block of code, all the book objects allocated
		// here will be in memory regardless of whether we use autorelease or release, because they are
		// retained by the books array.
		Asset *asset = [[Asset alloc] initWithPrimaryKey:pk database:database];
		[asset fromDB];
		[assetArray addObject:asset];
		[asset release];
	}
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_cat_statement);
    return assetArray;
}

+ (NSMutableArray *)retrieveAllAssets:(sqlite3 *)database byContainer:(NSInteger)container
{
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_loc_statement == nil) {
		//static char *sql = "SELECT * FROM asset ORDER BY `name`";
		static char *sql = "SELECT * FROM asset where containerID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_loc_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(retrieve_all_loc_statement, 1, container);
	
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
	
	// We "step" through the results - once for each row.
	while (sqlite3_step(retrieve_all_loc_statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int pk = sqlite3_column_int(retrieve_all_loc_statement, 0);
		// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
		// autorelease is slightly more expensive than release. This design choice has nothing to do with
		// actual memory management - at the end of this block of code, all the book objects allocated
		// here will be in memory regardless of whether we use autorelease or release, because they are
		// retained by the books array.
		Asset *asset = [[Asset alloc] initWithPrimaryKey:pk database:database];
		[assetArray addObject:asset];
		[asset release];
	}
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_loc_statement);
    return assetArray;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (retrieve_statement) sqlite3_finalize(retrieve_statement);
    if (retrieve_all_statement) sqlite3_finalize(retrieve_all_statement);
    if (retrieve_all_cat_statement) sqlite3_finalize(retrieve_all_cat_statement);
    if (retrieve_all_loc_statement) sqlite3_finalize(retrieve_all_loc_statement);
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
			const char *sql = "DELETE FROM asset WHERE pk=?";
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
        const char *sql = "SELECT * FROM asset WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement, 1, pk);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        self.catID = (NSInteger)sqlite3_column_int(hydrate_statement, 1);
        self.containerID = (NSInteger)sqlite3_column_int(hydrate_statement, 2);
        char *str = (char *)sqlite3_column_text(hydrate_statement, 3);
        self.name = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.quantity = (NSInteger)sqlite3_column_int(hydrate_statement, 4);
        self.cost = (double)sqlite3_column_double(hydrate_statement, 5);
        self.acqrDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(hydrate_statement, 6)];
		str = (char *)sqlite3_column_text(hydrate_statement, 7);
        self.notes = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 8);
        self.fieldvalue1 = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 9);
        self.fieldvalue2 = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.serverpk = (NSInteger)sqlite3_column_int(hydrate_statement, 10);
	} else {
        // The query did not return 
        self.name = @"";
		self.catID=kUnassignedCatID;
		self.containerID=kUnassignedContainerID;
        self.acqrDate = [NSDate date];
    }
	// Reset the query for the next use.
	sqlite3_reset(hydrate_statement);
	
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
	// Write any changes to the database.
	// First, if needed, compile the dehydrate query.
	if (dehydrate_statement == nil) {
		const char *sql = "UPDATE asset SET name=?, quantity=?, cost=?, acqrDate=?, notes=?, catID=?, containerID=?,fieldvalue1=?, fieldvalue2=?, serverpk=? WHERE pk=?";
		if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	// Bind the query variables.
	sqlite3_bind_text(dehydrate_statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 2, quantity);
	sqlite3_bind_double(dehydrate_statement, 3, cost);
	sqlite3_bind_double(dehydrate_statement, 4, [acqrDate timeIntervalSince1970]);
	sqlite3_bind_text(dehydrate_statement, 5, [notes UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 6, catID);
	sqlite3_bind_int(dehydrate_statement, 7, containerID);
	sqlite3_bind_text(dehydrate_statement, 8, [fieldvalue1 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 9, [fieldvalue2 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 10, serverpk);
	sqlite3_bind_int(dehydrate_statement, 11, pk);

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
	Asset *crs=(Asset *)anObject;
	if(crs != nil && crs.pk == self.pk)
		return TRUE;
	else
		return FALSE;
}


+(UIImage *)scaleAndRotateImage:(UIImage *)image
{
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

+(BOOL)uploadAllAssets:(sqlite3 *)database forUser:(User *)aUser
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload because there is no internet connection available."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		NSMutableArray *assList = [Asset retrieveAllAssets:database];
		NSURL *url = [NSURL URLWithString:@"http://www.jajsoftware.com/myassets/assets_upload.php"]; 
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		[request setHTTPMethod:@"POST"];
		
		NSMutableString *post = [NSMutableString stringWithFormat:@"userID=%i", aUser.serverpk];
		NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];

		NSInteger count=[assList count];
		for(int i=0; i <count; i++){
			Asset	*ass = [assList objectAtIndex:i];
			[post appendFormat:@"&pk[%i]=%i",i,ass.pk];
			[post appendFormat:@"&name[%i]=%@",i,ass.name];
			[post appendFormat:@"&quantity[%i]=%i",i,ass.quantity];
			[post appendFormat:@"&cost[%i]=%f",i,ass.cost];
			[post appendFormat:@"&acqrDate[%i]=%@",i,[dateFormat stringFromDate:ass.acqrDate]];
			[post appendFormat:@"&notes[%i]=%@",i,ass.notes];
			[post appendFormat:@"&catID[%i]=%i",i,ass.catID];
			[post appendFormat:@"&containerID[%i]=%i",i,ass.containerID];
			[post appendFormat:@"&fieldvalue1[%i]=%@",i,ass.fieldvalue1];
			[post appendFormat:@"&fieldvalue2[%i]=%@",i,ass.fieldvalue2];
		}
		
		[dateFormat release];
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
			[Asset uploadAllImages:assList];
			return [str intValue];
			
		}
	}
	return 0;
}	


+(void)uploadAllImages:(NSMutableArray *)assList
{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSInteger count=[assList count];
	for(int i=0; i <count; i++){
		Asset	*ass = [assList objectAtIndex:i];
		if(ass.serverpk == 0){
			BOOL bool1=TRUE, bool2=TRUE, bool3=TRUE, bool4=TRUE;
			NSString *imgStr= [AddAssetViewController getPhotoPath:1 forAsset:ass];
			if( [fileManager fileExistsAtPath:imgStr])
				bool1=[ass uploadImage:imgStr];
			imgStr= [AddAssetViewController getPhotoPath:2 forAsset:ass];
			if( [fileManager fileExistsAtPath:imgStr])
				bool2=[ass uploadImage:imgStr];
			imgStr= [AddAssetViewController getPhotoPath:3 forAsset:ass];
			if( [fileManager fileExistsAtPath:imgStr])
				bool3=[ass uploadImage:imgStr];
			imgStr= [AddAssetViewController getPhotoPath:4 forAsset:ass];
			if( [fileManager fileExistsAtPath:imgStr])
				bool4=[ass uploadImage:imgStr];
			if(bool1 && bool2 && bool3 && bool4){
				ass.serverpk=1;
				[ass toDB];
			}
		}
	}
	
}
-(void)deleteAllImages
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *imgStr= [AddAssetViewController getPhotoPath:1 forAsset:self];
	if( [fileManager fileExistsAtPath:imgStr]){
		NSError *error;
		[fileManager removeItemAtPath:imgStr error:&error];
	}
	imgStr= [AddAssetViewController getPhotoPath:2 forAsset:self];
	if( [fileManager fileExistsAtPath:imgStr]){
		NSError *error;
		[fileManager removeItemAtPath:imgStr error:&error];
	}
	imgStr= [AddAssetViewController getPhotoPath:3 forAsset:self];
	if( [fileManager fileExistsAtPath:imgStr]){
		NSError *error;
		[fileManager removeItemAtPath:imgStr error:&error];
	}
	imgStr= [AddAssetViewController getPhotoPath:4 forAsset:self];
	if( [fileManager fileExistsAtPath:imgStr]){
		NSError *error;
		[fileManager removeItemAtPath:imgStr error:&error];
	}
}

-(BOOL)uploadImage:(NSString *)imgStr
{
	NSLog(imgStr);
	NSData *imageData=[[NSData alloc] initWithContentsOfFile:imgStr];
	UIDevice *dev = [UIDevice currentDevice];
	NSString *uniqueId = dev.identifierForVendor.UUIDString;
	
	NSString *urlString = [@"http://www.jajsoftware.com/myassets/image_upload.php?" stringByAppendingFormat:@"udid=%@", uniqueId];
	// urlString = [urlString stringByAppendingString:@"&lang=en_US.UTF-8"];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	// [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	// [request setValue:@"application/" forHTTPHeaderField:@"Content-Length"];
	
	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	
	/* 
	 //add key values from the NSDictionary object
	 NSEnumerator *keys = [postKeys keyEnumerator];
	 int i;
	 for (i = 0; i < [postKeys count]; i++) {
	 NSString *tempKey = [keys nextObject];
	 [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
	 [postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
	 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	 }
	 */
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", imgStr] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:imageData]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// ---------
	[request setHTTPBody:postBody];
	NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(conn) {
		receivedData = [[NSMutableData data] retain];
		[conn retain];	
		NSLog(@"image posted");
		return TRUE;
	} else {
		NSLog(@"photo: upload failed!");
		return FALSE;
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{ 
	// this method is called when the server has determined that it 
	// has enough information to create the NSURLResponse 
	// it can be called multiple times, for example in the case of a 
	// redirect, so each time we reset the data. 
	// receivedData is declared as a method instance elsewhere 
	[receivedData setLength:0]; 
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{ 
	// append the new data to the receivedData 
	// receivedData is declared as a method instance elsewhere 
	[receivedData appendData:data]; 
} 


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
	// release the connection, and the data object
	[connection release]; 
	// receivedData is declared as a method instance elsewhere 
	[receivedData release]; 
	// inform the user 
	NSLog(@"Connection failed! Error - %@ %@", 
		  [error localizedDescription], 
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]); 
} 

- (unsigned char*) getData
{
	int urlLength = [receivedData length];
	unsigned char *downloadBuffer;
	
	downloadBuffer = (unsigned char*) malloc (urlLength);
	
	[receivedData getBytes: (unsigned char*)downloadBuffer];
	
	return downloadBuffer;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
	// do something with the data 
	// receivedData is declared as a method instance elsewhere 
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]); 
	// release the connection, and the data object 
	NSLog([NSString stringWithFormat:@"%P", [receivedData bytes]]); 
	
}


@end

