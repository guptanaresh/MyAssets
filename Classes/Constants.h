/* weightbot, colors, icoria apps
 Instrument and shark
 transition instrument for ui
 simulator app: ~/Library/Application Support/iPhone Simulator/
 */





#define kAppVersion 1
#define kAllowAd FALSE
#define AD_REFRESH_PERIOD 8
#define kAdBottom 0
#define kAdTop 2
#define kAdID1 @"a1490ec3786e764"
#define kAdID2 @"a1490e700c9fea0"
#define kDatabaseFile	@"myassets.sql"
#define kMaxResolution  320

#define kUnassignedStr @"Unassigned"
#define kUnassignedContainerID 1
#define kUnassignedCatID 1

#define kStringFieldType @"string"
#define kDateEnterString @"Date"
#define kCostFormat @"%10.2f"
#define kSplashDelay 2.0

#define kImageQuality @"image_quality"

#define kServiceBackup 1
#define kMyAssets_BackupProductIdentifier @"MyAssetsOnlineBackup"


#define kAssetsTab 0
#define kCategoriesTab 1
#define kPlacesTab 2
#define kBackupTab 3


//version 2 changes
#define kAppVersion2Upgrade1 "ALTER TABLE coursehole ADD 'holeType' INTEGER"
#define kAppVersion2Upgrade2 "ALTER TABLE coursehole ADD 'teeLongitude' DOUBLE"
#define kAppVersion2Upgrade3 "ALTER TABLE coursehole ADD 'teeLatitude' DOUBLE"
#define kAppVersion2Upgrade4 "ALTER TABLE coursehole ADD 'frontLongitude' DOUBLE"
#define kAppVersion2Upgrade5 "ALTER TABLE coursehole ADD 'frontLatitude' DOUBLE"
#define kAppVersion2Upgrade6 "ALTER TABLE coursehole ADD 'backLongitude' DOUBLE"
#define kAppVersion2Upgrade7 "ALTER TABLE coursehole ADD 'backLatitude' DOUBLE"


//version 4 changes
#define kAppVersion4Upgrade1 "ALTER TABLE score ADD 'teeType' INTEGER"
#define kAppVersion4Upgrade2 "ALTER TABLE hole ADD 'puttNum' INTEGER"
#define kAppVersion4Upgrade3 "ALTER TABLE hole ADD 'puttNum2' INTEGER"
#define kAppVersion4Upgrade4 "ALTER TABLE hole ADD 'puttNum3' INTEGER"
#define kAppVersion4Upgrade5 "ALTER TABLE hole ADD 'puttNum4' INTEGER"


//version 5 changes: added user table
#define kAppVersion5Upgrade1 "CREATE TABLE user ('pk' INTEGER, 'serverpk' INTEGER, 'username' CHAR(48), 'password' CHAR(48), 'udid' CHAR(48), 'service' INTEGER)"
#define kAppVersion5Upgrade2 "ALTER TABLE score ADD 'serverpk' INTEGER"
#define kAppVersion5Upgrade3 "ALTER TABLE course ADD 'courseAddress' CHAR(100)"
#define kAppVersion5Upgrade4 "ALTER TABLE course ADD 'courseCity' CHAR(25)"
#define kAppVersion5Upgrade5 "ALTER TABLE course ADD 'courseState' CHAR(25)"
#define kAppVersion5Upgrade6 "ALTER TABLE course ADD 'courseCountry' CHAR(25)"
#define kAppVersion5Upgrade7 "ALTER TABLE course ADD 'coursePhone' CHAR(50)"
#define kAppVersion5Upgrade8 "ALTER TABLE course ADD 'courseWebsite' CHAR(50)"
#define kAppVersion5Upgrade9 "ALTER TABLE course ADD 'courseZipcode' CHAR(25)"
#define kAppVersion5Upgrade10 "update app set appVersion=5 where pk=1"


//version 6 changes
#define kAppVersion6Upgrade1 "ALTER TABLE score ADD 'gameType' INTEGER"
#define kAppVersion6Upgrade2 "update app set appVersion=6 where pk=1"


//version 7 changes
#define kAppVersion7Upgrade1 "ALTER TABLE user ADD 'playerName' TEXT"
#define kAppVersion7Upgrade2 "ALTER TABLE user ADD 'contactID' INTEGER"
#define kAppVersion7Upgrade3 "ALTER TABLE user ADD 'fbUID' INTEGER"
#define kAppVersion7Upgrade12 "ALTER TABLE user ADD 'latestHI' REAL"
#define kAppVersion7Upgrade4 "ALTER TABLE score ADD 'hi' REAL"
#define kAppVersion7Upgrade5 "ALTER TABLE score ADD 'hi2' REAL"
#define kAppVersion7Upgrade6 "ALTER TABLE score ADD 'hi3' REAL"
#define kAppVersion7Upgrade7 "ALTER TABLE score ADD 'hi4' REAL"
#define kAppVersion7Upgrade8 "ALTER TABLE score ADD 'latestHI' REAL"
#define kAppVersion7Upgrade9 "ALTER TABLE score ADD 'fbUID2' INTEGER"
#define kAppVersion7Upgrade10 "ALTER TABLE score ADD 'fbUID3' INTEGER"
#define kAppVersion7Upgrade11 "ALTER TABLE score ADD 'fbUID4' INTEGER"
#define kAppVersion7Upgrade13 "update app set appVersion=7 where pk=1"

//version 8 is data update

//version 9 changes
#define kAppVersion9Upgrade1 "ALTER TABLE score ADD 'scoreType' INTEGER DEFAULT 0"
#define kAppVersion9Upgrade2 "update app set appVersion=9 where pk=1"

