

Documentation and samplecode for:

## **MacOS Local Notifications Plugin for Corona SDK**
https://marketplace.coronalabs.com/plugin/???


This plugin provides access to the Notification Center on MacOS.  It allows you to schedule/dispatch local notifications as banners or notification alerts. Banners are regular notifications and alerts are notifications with buttons or text reply fields.



## **Project Settings**
To use this plugin, add an entry into the plugins table of build.settings. If you want your application to throw alert style notifications you need to add the NSUserNotificationAlertStyle = "alert" entry in the build settings plist table (default style is banner). After this you can import the plugin with:

```lua
settings =
{
    plugins =
    {
        ["plugin.notifications.macos"] = { publisherId = "net.shakebrowser" }
    },
     macos =
    {
        plist =
        {
		-- Add this entry if you want alert style notifications
		NSUserNotificationAlertStyle = "alert",
        },
    },
}
```
After this you import the plugin with:
```lua
local notifications = require "plugin.notifications.macos"
```


## **Functions**
#### **notifications.scheduleNotification( [secondsFromNow], options )**

Schedules a notification and returns a notification id (string)

**secondsFromNow** number (optional)

The time in seconds (from now)  that the notification will dispatch. If you omit this parameter the notification will be dispatched instead of scheduled.

**options**( table)

A table containing the options of the notification. See options example below.

```lua
local options = {

	title = "Some Title",
	subtitle = "a subtitle", -- optional
	message = "Message of the notification",
	
	-- By default notifications will not be presented if the application is active.
	-- This option forces it to present itself.
	presentWhenApplicationIsActive = true, -- optional
	
	-- Optional content image on the notification. Either path or url can be supplied.
	-- contentImagePath will overrule contentImageUrl if both are supplied.
	contentImageUrl = "https://placehold.it/300", -- optional
	contentImagePath = system.pathForFile( "smiley.png", system.ResourceDirectory ), -- optional
	
	-- Options below are only available for alert style notifications.
	-- these requires you to add the plist entry: NSUserNotificationAlertStyle = "alert"
	-- Alerts can have either action buttons or reply fields - not both.
	-- Action buttons will overrule reply fields if both options are set to true.
	hasActionButton = true, -- optional
	actionButtonTitle = "OK", -- optional
	otherActionButtonTitle = "Cancel", -- optional
	hasReplyButton = true, -- optional
}
```

#### notifications.removeScheduledNotification( notificationId )
Cancels and removes a scheduled notification.

#### notifications.removeDeliveredNotification([notificationId])
Removes a delivered notification from the notification center of MacOS. If you omit the notificationId this call will remove all delivered notifications coming from your application.

#### notifications.getScheduledNotifications()
Returns a table with information about all the notifications your app has scheduled.

#### notifications.getDeliveredNotifications()
Returns a table with information about all the notifications your app has delivered (visible in the notification center).

#### notifications.setBadge([string])
Sets the application icon badge. If nil is passed it will clear the badge. Notice you can use the badge to write a message or as a counter by passing in a number casted as a string.



## **Handling Notification Events**


In accordance with the Corona event/listener model, if your app is running in either the foreground or background and a notification arrives, you'll receive a notification event. It's your responsibility to initialize the system and set up a listener function to handle these events.

```lua
local function notificationListener( event )
	
    if ( event.type == "didDeliverNotification" ) then
        -- The notification was delivered
 
    elseif ( event.type == "didActivateNotification" ) then
        -- User activated the notification
 
    end
end

Runtime:addEventListener( "notification", notificationListener )
```

### Notification Event Data
A notification event returns a table of information which you can use to manage the specific notification. This table includes the following:

**event.notificationId** (string) the unique id that was returned when the notification was scheduled.

**event.type** (string) can be "didDeliverNotification" or "didActivateNotification"

**event.deliveryTimestamp** (number) a timestamp representing the delivery time (in unix time GMT)

**event.response** (string) the text the user entered - if the notification had a reply button.

**event.activationType** (number) a number representing if/how the user interacted with the notification. Possible values are listed below:

- 0 - The user did not interact with the notification alert.
- 1 - contentsClicked: The user clicked on the contents of the notification alert.
- 2 - actionButtonClicked: The user clicked on the action button of the notification alert.
- 3 - replied: The user replied to the notification (in the text field).
- 4 - additionalActionClicked: The user clicked on the additional action button of the notification alert.


## **Gotchas**
- Banner style notifications will show in the Corona Simulator, but alert style notifications will show as banner style notifications too (no buttons or reply fields will show). To test alerts you need create a build for MacOS.

## **Examples**
Sample code can be found in this repository.
