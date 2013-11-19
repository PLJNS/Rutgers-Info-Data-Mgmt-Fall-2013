//
//  RUDBManager.m
//  Drink.io
//
//  Created by Paul Jones on 11/18/13.
//  Copyright (c) 2013 Principles of Informations and Data Management. All rights reserved.
//

#import "RUDBManager.h"
static RUDBManager *sharedInstance = nil;

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation RUDBManager

+ (RUDBManager *) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    
    return sharedInstance;
}

- (BOOL) addFriendWithFirstName: (NSString *) firstName
                   withLastName: (NSString *) lastName
                      withPhone: (NSString *) phone
                     withStreet: (NSString *) street
                       withCity: (NSString *) city
                      withState: (NSString *) state
                        withZip: (NSString *) zip
                    withCountry: (NSString *) country
                withCountryCode: (NSString *) countryCode
                andWithFavorite: (NSInteger *) favorite {
    return false;
}

- (BOOL)   addBarWithName: (NSString *) bar
          withPhoneNumber: (NSString *) phoneNumber
                  withURL: (NSString *) URL
         withThoroughfare: (NSString *) thoroughfare
      withSubThoroughfare: (NSString *) subThoroughfare
             withLocality: (NSString *) locality
          withSubLocality: (NSString *) subLocality
   withAdministrativeArea: (NSString *) administrativeArea
withSubAdministrativeArea: (NSString *) subAdministrativeArea
           withPostalCode: (NSString *) postalCode
       withISOcountryCode: (NSString *) ISOcountryCode
              withCountry: (NSString *) country
          andWithFavorite: (NSInteger) favorite {
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into bars"
                               "(bar,phoneNumber,URL,throughfare,subThroughfare,locality,subLocality,"
                               "administrativeArea, subAdministrativeArea, postalCode, ISOcountryCode,"
                               "country, favorite)"
                               "values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\")",
                               bar, phoneNumber, URL, thoroughfare, subThoroughfare, locality, subLocality, administrativeArea,
                               subAdministrativeArea, postalCode, ISOcountryCode, country, favorite];
        
        NSLog(@"%@", insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}

- (BOOL) makeBestFriendWithFirstName: (NSString *) firstName
                        withLastName: (NSString *) lastName
                        andWithPhone: (NSString *) phone {
    
    return false;
}

- (BOOL) makeFavoriteBarWithPhone: (NSString *) phone {
    
    return false;
}

- (NSArray *) getFriends {
    NSArray * friends = [[NSArray alloc] init];
    
    return friends;
}
- (NSArray *) getBestFriends {
    NSArray * bestFriends = [[NSArray alloc] initWithObjects:@"Paul Jones",@"Frank Porco", @"Tomasz Imielinski", nil];
    
    return bestFriends;
}
- (NSArray *) getBars {
    NSArray * bars = [[NSArray alloc] init];
    
    return bars;
}
- (NSArray *) getFavoriteBars {
    NSArray * favoriteBars = [[NSArray alloc] initWithObjects:@"Clydz",@"Harvest Moon", @"Stuff Yer Face", nil];
    
    return favoriteBars;
}

- (BOOL) createDB {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"barbeerdrinker.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:@"/initializeDB" ofType:@"txt"];
        NSString * dbInit = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
        [self createTableWith:dbInit];
    }
    return isSuccess;
}

- (BOOL) createTableWith: (NSString *) sqlStatement {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [sqlStatement UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            return NO;
            NSLog(@"Failed to create table");
        }
        sqlite3_close(database);
        return YES;
    }
    else {
        return NO;
        NSLog(@"Failed to open/create database");
    }
}

- (NSString *) query: (NSString *) querySQL {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                return name;
            }
            else{
                return @"Failed";
            }
            sqlite3_reset(statement);
        }
    }
    
    return @"Failed";
}

- (BOOL) saveData:(NSString*)registerNumber name:(NSString*)name department:(NSString*)department year:(NSString*)year;
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into studentsDetail (regno,name, department, year) values (\"%d\",\"%@\", \"%@\", \"%@\")",
                               [registerNumber integerValue],
                               name, department, year];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}

- (NSArray*) findByRegisterNumber:(NSString*)registerNumber
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select name, department, year from studentsDetail where regno=\"%@\"",registerNumber];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
                NSString *department = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:department];
                NSString *year = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:year];
                return resultArray;
            }
            else{
                NSLog(@"Not found");
                return nil;
            }
            sqlite3_reset(statement);
        }
    }
    return nil;
}

@end

