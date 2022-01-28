//
//  PluginNotifications.mm
//
//  Copyright (c) 2017 Jacob Nielsen. All rights reserved.
//

#import "PluginNotifications.h"
#include "CoronaRuntime.h"

#import <Foundation/Foundation.h>


// ----------------------------------------------------------------------------

@interface Delegate : NSObject <NSUserNotificationCenterDelegate>
	@property (nonatomic, assign) lua_State *L; // Pointer to the current Lua state
@end

// -----------------------------------------------------------------------------

class PluginNotifications
{
public:
    typedef PluginNotifications Self;
    
public:
    static const char kName[];
    static const char kEvent[];
    
protected:
    PluginNotifications();
    
public:
    bool Initialize( CoronaLuaRef listener );
    
public:
    CoronaLuaRef GetListener() const { return fListener; }
    
public:
    static int Open( lua_State *L );
    
protected:
    static int Finalizer( lua_State *L );
    
public:
    static Self *ToLibrary( lua_State *L );
    
public:
    static int scheduleNotification( lua_State *L );
    static int removeScheduledNotification( lua_State *L );
    static int removeDeliveredNotification( lua_State *L );
    static int removeAllDelivered( lua_State *L );
    static int getDeliveredNotifications( lua_State *L );
    static int getScheduledNotifications( lua_State *L );
	static int setBadge( lua_State *L );
    
private:
    CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginNotifications::kName[] = "plugin.notifications.macos";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginNotifications::kEvent[] = "notifications";

PluginNotifications::PluginNotifications()
:	fListener( NULL )
{
}

bool
PluginNotifications::Initialize( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == fListener );
    
    if ( result )
    {
        fListener = listener;
    }
    
    return result;
}

int
PluginNotifications::Open( lua_State *L )
{
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
    
    // Functions in library
    const luaL_Reg kVTable[] =
    {
        { "scheduleNotification", scheduleNotification },
        { "removeScheduledNotification", removeScheduledNotification },
        { "removeDeliveredNotification", removeDeliveredNotification },
        { "getDeliveredNotifications", getDeliveredNotifications },
        { "getScheduledNotifications", getScheduledNotifications },
		{ "setBadge", setBadge },
        
        { NULL, NULL }
    };
    
    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata( L, library, kMetatableName );
    
    luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack
    
    return 1;
}

int
PluginNotifications::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
    
    CoronaLuaDeleteRef( L, library->GetListener() );
    
    delete library;
    
    return 0;
}

PluginNotifications *
PluginNotifications::ToLibrary( lua_State *L )
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
    return library;
}

// -------------------------------------------------------------------
NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
Delegate *delegate = [[Delegate alloc] init];

NSDockTile *dockTile = [NSApp dockTile];

// [Lua] notifications.setBadge( number )
int PluginNotifications::setBadge( lua_State *L )
{
	const char *badge = NULL;
	if ( lua_type( L, -1 ) == LUA_TSTRING  )
	{
		badge = lua_tostring( L, -1 );
	} else {
		luaL_error( L, "You need to pass a string." );
	}
	lua_pop( L, 1 );
	
	NSString *label = NULL;
	if ( badge )
	{
		label = [NSString stringWithUTF8String:badge];
	}
	
	[dockTile setBadgeLabel:label];
	
    return 0;
}

// Schedule notification
int
PluginNotifications::scheduleNotification( lua_State *L )
{

	// Params passed
	double seconds = lua_tonumber( L, 1);
	const char *title = nil;
    const char *subtitle = nil;
    const char *message = nil;
    const char *contentImagePath = nil;
    const char *contentImageUrl = nil;
	bool hasActionButton = NO;
	const char *actionButtonTitle = nil;
	const char *otherActionButtonTitle = nil;
	bool hasReplyButton = NO;
    bool presentWhenActive = NO;

	if ( lua_type( L, -1 ) == LUA_TTABLE )
	{
		// Notification title
		lua_getfield( L, -1, "title" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            title = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
		// Notification subtitle
		lua_getfield( L, -1, "subtitle" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            subtitle = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
        // Notification message
		lua_getfield( L, -1, "message" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            message = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
		// Notification image file
		lua_getfield( L, -1, "contentImagePath" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            contentImagePath = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
		// Notification image url
		lua_getfield( L, -1, "contentImageUrl" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            contentImageUrl = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
        // Alert action button
		lua_getfield( L, -1, "hasActionButton" );
        if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
        {
            hasActionButton = lua_toboolean( L, -1);
        }
        lua_pop( L, 1 );
		
		// Reply action button
		lua_getfield( L, -1, "hasReplyButton" );
        if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
        {
            hasReplyButton = lua_toboolean( L, -1);
        }
        lua_pop( L, 1 );

        // Action button title
		lua_getfield( L, -1, "actionButtonTitle" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            actionButtonTitle = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
        // Other action button title
		lua_getfield( L, -1, "otherActionButtonTitle" );
        if ( lua_type( L, -1 ) == LUA_TSTRING )
        {
            otherActionButtonTitle = lua_tostring( L, -1 );
        }
        lua_pop( L, 1 );
		
        // Notification present when application active
		lua_getfield( L, -1, "presentWhenApplicationIsActive" );
        if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
        {
            presentWhenActive = lua_toboolean( L, -1);
        }
        lua_pop( L, 1 );
	} else {
		luaL_error( L, "You need to pass an options table." );
	}
	
	// Create uid for notification
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uid = [(NSString *)uuidStringRef autorelease];
	
	// Assign delegate
	delegate.L = L;
	[center setDelegate:delegate];
	
	//Initalize new notification
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	
	[notification setTitle:[NSString stringWithUTF8String:title]];
	[notification setSubtitle:[NSString stringWithUTF8String:subtitle]];
	[notification setInformativeText:[NSString stringWithUTF8String:message]];
    [notification setIdentifier:uid];
    
    if ( contentImagePath ) {
		[notification setContentImage:[[NSImage alloc]initWithContentsOfFile:[NSString stringWithUTF8String:contentImagePath]]];
	} else if ( contentImageUrl ) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:contentImageUrl]];
		[notification setContentImage:[[NSImage alloc]initWithContentsOfURL:url]];
    }
	
    // Action buttons
	if ( hasActionButton ) {
		hasReplyButton = NO;
	}
	
	[notification setHasActionButton:hasActionButton];
	[notification setHasReplyButton:hasReplyButton];
	if ( actionButtonTitle) {
		[notification setActionButtonTitle:[NSString stringWithUTF8String:actionButtonTitle]];
	}
	if ( otherActionButtonTitle) {
		[notification setOtherButtonTitle:[NSString stringWithUTF8String:otherActionButtonTitle]];
	}
	
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
	[userInfo setObject:[NSNumber numberWithBool:presentWhenActive] forKey:@"presentWhenActive"];
	[notification setUserInfo:userInfo];
	
	[notification setDeliveryDate:[NSDate dateWithTimeInterval:seconds sinceDate:[NSDate date]]];
	[notification setSoundName:NSUserNotificationDefaultSoundName];
	
	if ( ! seconds )
    {
		[center deliverNotification:notification];
    } else {
		[center scheduleNotification:notification];
	}
	
	lua_pushstring(L, [uid cStringUsingEncoding:NSASCIIStringEncoding]);
	
    return 1;
}

// Cancel notification
int
PluginNotifications::removeScheduledNotification( lua_State *L )
{

	const char *notificationId = lua_tostring( L, 1);
	
	Boolean removed = NO;
	
	if ( notificationId )
	{
		NSString *uid = [NSString stringWithUTF8String:notificationId];
		NSArray *scheduled = [center scheduledNotifications];
		for ( NSUserNotification *notification in scheduled) {
			if ( [notification.identifier isEqualToString:uid] )
			{
				//NSLog(@"Removing scheduled notifications %@", notification.identifier);
				[center removeScheduledNotification:notification];
				removed = YES;
			}
		}
	}
	
	lua_pushboolean(L, removed);
	
	return 1;
}

// Get scheduled notifications from center
int
PluginNotifications::getScheduledNotifications( lua_State *L )
{
	
	NSArray *scheduled = [center scheduledNotifications];
	lua_newtable( L );
	
	int count = 1;
	for ( NSUserNotification *notification in scheduled) {
		double stamp = [notification.deliveryDate timeIntervalSince1970];
		if ( stamp != 0 ) {
			lua_newtable( L );
			lua_pushnumber( L, stamp);
			lua_setfield( L, -2, "deliveryTimestamp" );
			lua_pushstring( L, [notification.identifier cStringUsingEncoding:NSASCIIStringEncoding]);
			lua_setfield( L, -2, "notificationId" );
			lua_pushnumber( L, stamp);
			lua_setfield( L, -2, "deliveryTimestamp" );
			lua_rawseti(L, -2, count);
			count += 1;
		}
	}
	
	return 1;
}

// Get delivered notifications from center
int
PluginNotifications::getDeliveredNotifications( lua_State *L )
{
	
	NSArray *delivered = [center deliveredNotifications];

	lua_newtable( L );
	
	int count = 1;
	for ( NSUserNotification *notification in delivered) {
		double stamp = [notification.deliveryDate timeIntervalSince1970];
		if ( stamp != 0 ) {
			lua_newtable( L );
			lua_pushnumber( L, stamp);
			lua_setfield( L, -2, "deliveryTimestamp" );
			lua_pushstring( L, [notification.identifier cStringUsingEncoding:NSASCIIStringEncoding]);
			lua_setfield( L, -2, "notificationId" );
			lua_pushnumber( L, (int)notification.activationType);
			lua_setfield( L, -2, "activationType" );
			lua_pushnumber( L, stamp);
			lua_setfield( L, -2, "deliveryTimestamp" );
			if ( (int)notification.activationType == 3 ) {
				lua_pushstring( L, [notification.response.string cStringUsingEncoding:NSASCIIStringEncoding]);
				lua_setfield( L, -2, "response" );
			}
			lua_rawseti(L, -2, count);
			count += 1;
		}
	}

	return 1;
}

// Remove delivered notification
int
PluginNotifications::removeDeliveredNotification( lua_State *L )
{
	const char *notificationId = lua_tostring( L, 1);
	
	if ( notificationId )
	{
		NSString *uid = [NSString stringWithUTF8String:notificationId];
		NSArray *delivered = [center deliveredNotifications];
		for ( NSUserNotification *notification in delivered) {
			if ( [notification.identifier isEqualToString:uid] )
			{
				[center removeDeliveredNotification:notification];
			}
		}
	} else {
		[center removeAllDeliveredNotifications];
	}
	return 0;
}

// Delegate ----------------------------------------------------------------------
@implementation Delegate

	- (void) userNotificationCenter:(NSUserNotificationCenter *)center
			didActivateNotification:(NSUserNotification *)notification
	{
		lua_State *L = self.L;
		
		double stamp = [notification.deliveryDate timeIntervalSince1970];
		
		const char kNameKey[] = "name";
		const char kValueKey[] = "notification";
		lua_newtable( L );
		lua_pushstring( L, kValueKey );
		lua_setfield( L, -2, kNameKey );
		lua_pushstring( L, [notification.identifier cStringUsingEncoding:NSASCIIStringEncoding]);
		lua_setfield( L, -2, "notificationId" );
		lua_pushstring( L, "didActivateNotification");
		lua_setfield( L, -2, "type" );
		lua_pushnumber( L, (int)notification.activationType);
		lua_setfield( L, -2, "activationType" );
		lua_pushnumber( L, stamp);
		lua_setfield( L, -2, "deliveryTimestamp" );
		if ( (int)notification.activationType == 3 ) {
			lua_pushstring( L, [notification.response.string cStringUsingEncoding:NSASCIIStringEncoding]);
			lua_setfield( L, -2, "response" );
		}
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}

	- (void) userNotificationCenter:(NSUserNotificationCenter *)center
			 didDeliverNotification:(NSUserNotification *)notification
	{
		lua_State *L = self.L;
		
		double stamp = [notification.deliveryDate timeIntervalSince1970];
		
		const char kNameKey[] = "name";
		const char kValueKey[] = "notification";
		lua_newtable( L );
	
		lua_pushstring( L, kValueKey );
		lua_setfield( L, -2, kNameKey );
		lua_pushstring( L, [notification.identifier cStringUsingEncoding:NSASCIIStringEncoding]);
		lua_setfield( L, -2, "notificationId" );
		lua_pushstring( L, "didDeliverNotification");
		lua_setfield( L, -2, "type" );
		lua_pushnumber( L, stamp);
		lua_setfield( L, -2, "deliveryTimestamp" );
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}

	- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center
		  shouldPresentNotification:(NSUserNotification *)notification
	{
		BOOL shouldPresent = [[notification.userInfo objectForKey:@"presentWhenActive"] boolValue];
		return shouldPresent;
	}

@end

// Export ------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_notifications_macos( lua_State *L )
{
    return PluginNotifications::Open( L );
}
