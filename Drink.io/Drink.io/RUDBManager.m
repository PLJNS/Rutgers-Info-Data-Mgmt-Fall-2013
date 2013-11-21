//
//  RUDBManager.m
//  Drink.io
//
//  Created by Paul Jones on 11/18/13.
//  Copyright (c) 2013 Principles of Informations and Data Management. All rights reserved.
//

#import "RUDBManager.h"
#import "RUBeer.h"

#define BARS_TABLE_NAME @"bars"
#define BEERS_TABLE_NAME @"beers"
#define DRINKER_TABLE_NAME @"drinkers"
#define DISTANCE_TABLE_NAME @"distance"
#define SELLS_TABLE_NAME @"sells"
#define LIKES_TABLE_NAME @"likes"
#define FREQUENTS_TABLE_NAME @"frequents"

static RUDBManager *sharedInstance = nil;

@implementation RUDBManager

+ (RUDBManager *) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDatabase];
    }
    
    return sharedInstance;
}

- (void) createDatabase {
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"drinkwithfriends.sqlite"];
    BOOL alreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    
    if (!alreadyExists){
        [self createTable:BEERS_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"name char(64)",
                           @"manf char(64)",
                           nil]];
        
        [self createTable:BARS_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"name char(64)",
                           @"phoneNumber char(64) primary key not null",
                           @"url char(64)",
                           @"thoroughfare char(64)",
                           @"subThoroughfare char(64)",
                           @"locality char(64)",
                           @"subLocality char(64)",
                           @"administrativeArea char(64)",
                           @"subAdministrativeArea char(64)",
                           @"postalCode char(64)",
                           @"ISOcountryCode char(64)",
                           @"country char(64)",
                           @"int favorite",
                           nil]];
        
        [self createTable:DRINKER_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"firstName char(64)",
                           @"lastName char(64)",
                           @"phone char(20)",
                           @"street char(64)",
                           @"city char(64)",
                           @"state char(64)",
                           @"zip char(64)",
                           @"country char(64)",
                           @"int favorite",
                           nil]];
        
        [self createTable:SELLS_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"bar char(64)",
                           @"beer char(64)",
                           @"price real",
                           nil]];
        
        [self createTable:LIKES_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"drinker char(20)",
                           @"beer char(20)",
                           nil]];
        
        [self createTable:FREQUENTS_TABLE_NAME
        andWithParameters:[[NSArray alloc] initWithObjects:
                           @"drinker char(20)",
                           @"bar char(20)",
                           nil]];
        
        [self insertBeerWithName:@"Bud Light" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Budweiser" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Coors Light" andManufacturer:@"Millercoors Brewing"];
        [self insertBeerWithName:@"Miller Lite" andManufacturer:@"Millercoors Brewing"];
        [self insertBeerWithName:@"Natural Light" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Corona Extra" andManufacturer:@"Crown Imports"];
        [self insertBeerWithName:@"Busch Light" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Busch" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Heineken" andManufacturer:@"Heineken"];
        [self insertBeerWithName:@"Michelob Ultra" andManufacturer:@"Anheuser-Busch InBev"];
        [self insertBeerWithName:@"Miller High Life" andManufacturer:@"Millercoors Brewing"];
        [self insertBeerWithName:@"Keystone Light" andManufacturer:@"Millercoors Brewing"];
        [self insertBeerWithName:@"Natural Ice" andManufacturer:@"Anheuser Busch InBev"];
        [self insertBeerWithName:@"Modelo Especial" andManufacturer:@"Crown Imports"];
        [self insertBeerWithName:@"Bud Light Lime" andManufacturer:@"Anheuser Busch InBev"];
        [self insertBeerWithName:@"Icehouse" andManufacturer:@"Millercoors Brewing"];
        [self insertBeerWithName:@"Bud Ice" andManufacturer:@"Anheuser Busch InBev"];
        [self insertBeerWithName:@"PBR" andManufacturer:@"Pabst Brewing Co."];
        [self insertBeerWithName:@"Yuengling Lager" andManufacturer:@"D G Yuengling & Sons"];
        [self insertBeerWithName:@"Corona Light" andManufacturer:@"Crown Imports"];
    }
    
}
- (BOOL) executeUpdate: (NSString *) update {
    return [db executeUpdate:update];
}

- (BOOL) insertBeerWithName: (NSString *) name andManufacturer: (NSString *) manf
{
    return [self insertIntoTable:BEERS_TABLE_NAME
                  withParameters:[[NSArray alloc] initWithObjects:
                                  name,
                                  manf,
                                  nil]];
}

- (NSMutableArray *) getBeers
{
    NSMutableString * query = [[NSMutableString alloc] initWithFormat:@"select * from beers"];
    NSMutableArray * response = [[NSMutableArray alloc] init];
    
    FMResultSet * rs = [db executeQuery:query];
    
    while ([rs next]) {
        NSString * name = [rs stringForColumn:@"name"];
        NSString * manf = [rs stringForColumn:@"manf"];
        
        [response addObject:[[RUBeer alloc] initWithName:name andWithManufacturer:manf]];
    }
    
    return response;
}

- (FMResultSet *) executeQuery: (NSString *) query
{
    return [db executeQuery:query];
}

- (BOOL) insertIntoTable: (NSString *) withName withParameters: (NSArray *) parameters
{
    
    NSMutableString * insertStatement = [[NSMutableString alloc] initWithFormat:@"insert into %@ values (", withName];
    
    for (int i = 0; i < [parameters count]; i++) {
        NSString * parameter = [parameters objectAtIndex:i];
        
        if (i < [parameters count] - 1)
            [insertStatement appendFormat:@"\"%@\",", parameter];
        else
            [insertStatement appendFormat:@"\"%@\"", parameter];
    }
    
    [insertStatement appendString:@");"];
    
    return [db executeUpdate:insertStatement];
}

- (void) createTable: (NSString *) withName andWithParameters: (NSArray *) parameters
{
    NSMutableString * update = [[NSMutableString alloc] initWithFormat:@"create table %@ (", withName];
    
    for (int i = 0; i < [parameters count]; i++) {
        NSString * parameter = [parameters objectAtIndex:i];
        if (i < [parameters count] - 1)
            [update appendFormat:@"%@,", parameter];
        else
            [update appendFormat:@"%@", parameter];
    }
    
    [update appendString:@");]"];
    
    if (![db executeUpdate:update])
        NSLog(@"WARNING! Table \"%@\" was not created!", withName);
}

- (NSString *) query: (NSString *) querySQL {
    return @"Interesting";
}

- (void) addFriendWithFirstName: (NSString *) firstName
                   withLastName: (NSString *) lastName
                      withPhone: (NSString *) phone
                     withStreet: (NSString *) street
                       withCity: (NSString *) city
                      withState: (NSString *) state
                        withZip: (NSString *) zip
                    withCountry: (NSString *) country
                withCountryCode: (NSString *) countryCode
                andWithFavorite: (NSInteger) favorite {
    
}

- (void)   addBarWithName: (NSString *) bar
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
    
}


- (void) makeBestFriendWithFirstName: (NSString *) firstName
                        withLastName: (NSString *) lastName
                        andWithPhone: (NSString *) phone {
}

- (void) makeFavoriteBarWithPhone: (NSString *) phone {
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

@end

