----------------------------------------------------------------------
--
-- Local Notifications for MacOS - Corona SDK Plugin Sample Project.
-- Banner notification example.
--
----------------------------------------------------------------------

local notifications = require "plugin.notifications.macos"
local inspect = require "inspect" -- library for inspecting lua tables

-- Add event listener for notification events
local function notificationListener( event )

	print (inspect(event)) 
	
    if ( event.type == "didDeliverNotification" ) then
        -- The notification was delivered
    elseif ( event.type == "didActivateNotification" ) then
        -- User activated the notification
        -- Remove the notification from the Notification Center in MacOS
        notifications.removeDeliveredNotification(event.notificationId)
    end
end
Runtime:addEventListener( "notification", notificationListener )


-- Notification options
local options = {
	title = "Local Notifications",
	subtitle = "for MacOSX",
	message = "Banner example",
	presentWhenApplicationIsActive = true,
	contentImagePath = system.pathForFile( "smiley.png", system.ResourceDirectory ),
}

-- Schedule notification 5 seconds from now
local notificationId = notifications.scheduleNotification(5, options)

-- Cancel the notification
-- notifications.removeScheduleNotification(notificationId)

-- Set badge on applications dock icon
notifications.setBadge("1")
