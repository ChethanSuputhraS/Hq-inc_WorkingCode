//
//  DataBaseManager.m
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import "DataBaseManager.h"
static DataBaseManager * dataBaseManager = nil;

@implementation DataBaseManager
#pragma mark - DataBaseManager initialization
-(id) init
{
    self = [super init];
    if (self)
    {
        // get full path of database in documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
        _dataBasePath = [path stringByAppendingPathComponent:@"HqIncApp.sqlite"];
        
        NSLog(@"data base path:%@",path);
        [self openDatabase];
    }
    return self;
}
+(DataBaseManager*)dataBaseManager
{
    static dispatch_once_t _singletonPredicate;
    dispatch_once(&_singletonPredicate, ^{
        if (!dataBaseManager)
        {
            dataBaseManager = [[super alloc]init];
        }
    });
    
    return dataBaseManager;
}

- (NSString *) getDBPath
{
    
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"HqIncApp.sqlite"];
}
-(void)openDatabase
{
    BOOL ok;
    NSError *error;
    
    /*
     * determine if database exists.
     * create a file manager object to test existence
     *
     */
    NSFileManager *fm = [NSFileManager defaultManager]; // file manager
    ok = [fm fileExistsAtPath:_dataBasePath];
    
    // if database not there, copy from resource to path
    if (!ok)
    {
        // location in resource bundle
        NSString *appPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"HqIncApp.sqlite"];
        if ([fm fileExistsAtPath:appPath])
        {
            // copy from resource to where it should be
            copyDb = [fm copyItemAtPath:appPath toPath:_dataBasePath error:&error];
            
            if (error!=nil)
            {
                copyDb = FALSE;
            }
            ok = copyDb;
        }
    }
    
    // open database
    
    if (sqlite3_open([_dataBasePath UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database); // in case partially opened
        _database = nil; // signal open error
    }
    
    if (!copyDb && !ok)
    {
        ok = [self Create_User_Table]; // create empty database
        if (ok)
        {
 
            
        }
    }
    if (!ok)
    {
        // problems creating database
        NSAssert1(0, @"Problem creating database [%@]",
                  [error localizedDescription]);
    }
}
-(BOOL)Create_User_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'User_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'name' VARCHAR, 'user_email' VARCHAR, 'user_pw' VARCHAR, 'is_active' VARCHAR,  'user_name' VARCHAR, 'device_token' VARCHAR,'device_type' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Sensor_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Sensor_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'session_id' VARCHAR, 'sensor_id' VARCHAR,  'sensor_type' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Monitor_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Monitor_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'user_name' VARCHAR, 'ble_address' VARCHAR, 'number' VARCHAR, 'is_active' VARCHAR, 'subject_id' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Record_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Record_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'user_id' VARCHAR, 'skin_temperature' VARCHAR, 'core_temperature' VARCHAR,  'date_time' VARCHAR,  'time_stamp' VARCHAR,  'check_type' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Subject_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Subject_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'name' VARCHAR, 'number' VARCHAR, 'photo_URL' VARCHAR, 'photo_URLThumbNail' VARCHAR, 'ing_highF' VARCHAR,'ing_lowF' VARCHAR, 'drml_highF' VARCHAR, 'drml_lowF' VARCHAR, 'ing_highC' VARCHAR,'ing_lowC' VARCHAR, 'drml_highC' VARCHAR, 'drml_lowC' VARCHAR, 'notes' VARCHAR, 'user_id' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Notes_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Notes_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'name' VARCHAR, 'notes' VARCHAR, 'date' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Alarm_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Alarm_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'high_ingest_F' VARCHAR, 'low_ingest_F' VARCHAR, 'high_dermal_F' VARCHAR, 'low_dermal_F' VARCHAR, 'high_ingest_C' VARCHAR, 'low_ingest_C' VARCHAR, 'high_dermal_C' VARCHAR, 'low_dermal_C' VARCHAR, 'battery_alarm' VARCHAR, 'quantity' VARCHAR, 'celciusSelect' VARCHAR)",nil];
    
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Session_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Session_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'session_id' VARCHAR, 'player_id' VARCHAR, 'player_name' VARCHAR, 'read_interval' VARCHAR, 'timeStamp' VARCHAR, 'no_of_sensor' VARCHAR, 'is_active' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_SessionData_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Session_data' ('id' INTEGER PRIMARY KEY  NOT NULL, 'session_id' VARCHAR, 'temp' VARCHAR, 'timestamp' VARCHAR, 'sensor_type' VARCHAR, 'sensor_id' VARCHAR, 'packet' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Insert Query
/*
 * Method to execute the simple queries
 */
-(BOOL)execute:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    return status;
}
-(int)executeSw:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    int  returnValue = sqlite3_last_insert_rowid( _database);
    
    return returnValue;
}

#pragma mark - SQL query methods
/*
 * Method to get the data table from the database
 */
-(BOOL) execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
    
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
        
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
                
                [row setValue:value forKey:key];
            }
            [dataTable addObject:row];
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}

-(BOOL) getJustValues:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
    
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
        
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
                [dataTable addObject:value];

//                [row setValue:value forKey:key];
            }
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}
-(NSInteger)getScalar:(NSString*)sqlStatement
{
    NSInteger count = -1;
    
    const char* sql= (const char *)[sqlStatement UTF8String];
    sqlite3_stmt *selectstmt;
    if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
            count = sqlite3_column_int(selectstmt, 0);
        }
    }
    sqlite3_finalize(selectstmt);
    
    return count;
}

-(NSString*)getValue1:(NSString*)sqlStatement
{
    
    NSString* value = nil;
    const char* sql= (const char *)[sqlStatement UTF8String];
    sqlite3_stmt *selectstmt;
    if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
            if ((char *)sqlite3_column_text(selectstmt, 0)!=nil)
            {
                value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
            }
        }
    }
    return value;
}



#pragma mark - Insert Query
/*
 * Method to execute the simple queries
 */
-(int)executeCatch:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    int  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

@end
