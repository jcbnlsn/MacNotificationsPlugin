----------------------------------------------------------------------
--
-- Local Notifications for MacOS - Corona SDK Plugin Sample Project.
-- Alert notification example - with buttons.
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
		if event.activationType == 2 then -- The user clicked on the action button.
			system.openURL("http://www.shakebrowser.net/corona-for-xcode/")
        end
    end
end
Runtime:addEventListener( "notification", notificationListener )

-- Notification options
local options = {
	title = "Local Notifications",
	subtitle = "for MacOSX",
	message = "Alert example with buttons",
	presentWhenApplicationIsActive = true,
	hasActionButton = true, -- optional
	actionButtonTitle = "More Info", -- optional
	otherActionButtonTitle = "Close", -- optional
	--contentImageUrl = "https://placehold.it/300",
}

-- Schedule notification 2 seconds from now
if not isSimulator then
	local notificationId = notifications.scheduleNotification(2, options)
	-- Set badge on applications dock icon
	notifications.setBadge("Alert")
else
	print ( "To test alert notifications you need to build for MacOS!!!")
end


