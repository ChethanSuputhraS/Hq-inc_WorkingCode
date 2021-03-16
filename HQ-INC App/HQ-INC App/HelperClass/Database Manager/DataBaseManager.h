//
//  DataBaseManager.h
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <sqlite3.h>
@interface DataBaseManager : NSObject
{
    NSString *path;
	NSString* _dataBasePath;
	sqlite3 *_database;
	BOOL copyDb;
    BOOL ret;
    BOOL status;
    BOOL querystatus;
}
+(DataBaseManager*)dataBaseManager;
-(NSString*) getDBPath;
-(void)openDatabase;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;
-(int)executeSw:(NSString*)sqlStatement;


#pragma mark- ***************
-(NSInteger)getScalar:(NSString*)sqlStatement;
-(NSString*)getValue1:(NSString*)sqlStatement;

-(BOOL)updateQuery:(NSDictionary *)dictInfo with:(NSString *)user_id;

-(BOOL)getJustValues:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;

-(BOOL)Create_User_Table;
-(BOOL)Create_Sensor_Table;
-(BOOL)Create_Monitor_Table;
-(BOOL)Create_Record_Table;
-(BOOL)Create_Subject_Table;
-(BOOL)Create_Notes_Table;
-(BOOL)Create_Alarm_Table;
-(BOOL)Create_Session_Table;
-(BOOL)Create_SessionData_Table;

@end







