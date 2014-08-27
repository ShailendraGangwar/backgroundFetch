//
//  Constants.h
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

typedef NS_ENUM(NSInteger, Filter)
{
    FilterNone = 1,
    FilterOneDay,
    FilterOneWeek,
    FilterOneMonth,
    FilterSearch,
};

typedef NS_ENUM(NSInteger, Type)
{
    TypeNone = 1,
    TypeITOSS,
    TypeNetwork,
    TypeFO,
    TypeISO
};

#define EMPTY_STRING                                @""
//#define IPS_SERVER_URL                              @"http://epttpoc.aricentcoe.com"
#define IPS_SERVER_URL                              @"http://212.183.133.169:16313"

#define REFRESH_TIME_INTERVAL                       60*20
#define HTTP_METHOD_POST                            @"POST"
#define HTTP_METHOD_GET                             @"GET"
#define DEVICEUDID                                  @"DeviceUDID"


#define MAINSTORYBOARD                              @"Storyboard"

#define APPLICATION_LAUNCH_FIRSTTIME                @"First Time"
#define DATA_WIPE_OUT                               @"Data Wipe Out"
#define USER_IN_HOME                                @"User in home"
#define DATA_ADDED                                  @"Is data added"
#define COLON                                       @":"
#define SETTINGS_SCREEN                             @"settings.html"
#define LOGIN_SCREEN                                @"index.html"
#define LOGIN_AUTHENTICATION                        @"username=&password=&commit=LOGIN"
#define GET_COMPLETE_DETAILS                        @"jsFnCall_CompleteDetails"
#define GET_REPLACE_DATA                            @"jsFnCall_ReplaceDB"

#define GET_INCIDENT_TYPE_DETAILS                   @"jsFnCall_dbTypeDetails"
#define GET_COMPLETE_LAST_24_HR_DETAILS             @"jsFnCall_dblastHourDetails"
#define GET_INCIDENT_TYPE_LAST_24_HR_DETAILS        @"jsFnCall_dblastHourDetails_Type"
#define GET_COMPLETE_LAST_WEEK_DETAILS              @"jsFnCall_dblastWeekDetails"
#define GET_INCIDENT_TYPE_LAST_WEEK_DETAILS         @"jsFnCall_dblastWeekDetails_Type"
#define GET_COMPLETE_LAST_MONTH_DETAILS             @"jsFnCall_dblastMonthDetails"
#define GET_INCIDENT_TYPE_LAST_MONTH_DETAILS        @"jsFnCall_dblastMonthDetails_Type"
#define GET_SEARCHED_COMPLETE_DETAILS               @"jsFnCall_INCDetails"
#define LOGOUT_CALL                                 @"jsFnCall_Logout"
#define JAVASCRIPT_TO_OBJC_FUNCTION_CALL            @"js-call:"
#define START_INDEX                                 @"startindex"
#define END_INDEX                                   @"endindex"
#define INCIDENT_TYPE                               @"type"
#define INCIDENT_IT_OSS                             @"IToss"
#define INCIDENT_NETWORK                            @"network"
#define INCIDENT_SEARCH_STRING                      @"val"
#define INCIDENT_FO                                 @"FO"
#define INCIDENT_ISO                                @"ISO"
#define INCIDENT_PARAMETRS                          @"parameters"
#define DIRECTORY_HTML                              @"www"

#define UIColorFromHexRGB(rgbHexValue) [UIColor colorWithRed:((float)((rgbHexValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbHexValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbHexValue & 0xFF))/255.0 alpha:1.0]

