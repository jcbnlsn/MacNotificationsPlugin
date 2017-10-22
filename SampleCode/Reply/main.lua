----------------------------------------------------------------------
--
-- Local Notifications for MacOS - Corona SDK Plugin Sample Project.
-- Alert notification example with reply text field.
--
-- Remeber to add the NSUserNotificationAlertStyle = "alert" entry in 
-- the build settings when using alert style notifications!!
--
----------------------------------------------------------------------

local notifications = require "plugin.notifications.macos"

local inspect = require "inspect" -- library for inspecting lua tables
local isSimulator = "simulator" == system.getInfo("environment")

-- Add event listener for notification events
local function notificationListener( event )
	
	print (inspect(event))
	
    if ( event.type == "didDeliverNotification" ) then
        -- The notification was delivered
    elseif ( event.type == "didActivateNotification" ) then
        -- User activated the notification. Handle the response.
	  if event.activationType == 3 then -- The user replied to the notification.
		  if event.response then
			  local text = "User replied: "..event.response
			  display.newText(text, display.contentCenterX, display.contentCenterY, native.systemFont, 25)
		  end
	  end
  end
end
Runtime:addEventListener( "notification", notificationListener )

-- Notification options
local options = {
	title = "Local Notifications",
	subtitle = "for MacOSX",
	message = "Alert example with reply",
	presentWhenApplicationIsActive = true,
	hasReplyButton = true
}

-- Schedule notification 2 seconds from now
if not isSimulator then
	local notificationId = notifications.scheduleNotification(2, options)
	-- Set badge on applications dock icon
	notifications.setBadge("Message")
else
	print ( "To test alert notifications you need to build for MacOS!!!")
end


