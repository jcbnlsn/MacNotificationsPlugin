//
//  PluginNotifications.h
//
//  Copyright (c) 2017 Jacob Nielsen. All rights reserved.

#ifndef _PluginNotifications_H__
#define _PluginNotifications_H__

#include "CoronaLua.h"
#include "CoronaMacros.h"

#import <Cocoa/Cocoa.h>

CORONA_EXPORT int luaopen_plugin_notifications( lua_State *L );

#endif // _PluginNotifications_H__
