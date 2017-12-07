scriptId = 'HCI Exercise - PowerPoint Connector'
scriptDetailsUrl = ''
scriptTitle = 'HCI Exercise - PowerPoint Connector'

myo.setLockingPolicy("none")

-- -------------------------- HCI 2017 EXERCISE ----------------------
-- My LUA SCRIPT BASIC
-- ========================== COMANDS ==========================
--Wave in to go to the next slide
--Wave out to go to the previous slide
--Finger spread to go to the first slide
--Fist to go to the last slide

PI = 3.1416 

function onForegroundWindowChange(app, title)
    local uppercaseApp = string.upper(app)
    return platform == "MacOS" and app == "com.microsoft.Powerpoint" or
        platform == "Windows" and (uppercaseApp == "POWERPNT.EXE" or uppercaseApp == "PPTVIEW.EXE")
end

function activeAppName()
    return "PowerPoint"
end

-- Effects

function forward()
    myo.keyboard("down_arrow", "press")
end

function backward()
    myo.keyboard("up_arrow", "press")
end

function firstslide()
	myo.keyboard("home","press")
end

function lastslide()
	myo.keyboard("end","press")
end	

function enterFullscreen()
	myo.keyboard("control-command-f","press")
end

function exitFullscreen()
	myo.keyboard("escape", "press")
end


-- Helpers

function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Shuttle

function shuttleBurst()
    if shuttleDirection == "forward" then
        forward()
    elseif shuttleDirection == "backward" then
        backward()
    end
end

-- Triggers

function onPoseEdge(pose, edge)

	if edge == "on" then
		-- Deal with direction and arm
		pose = conditionallySwapWave(pose)
		myo.debug(pose);
		local pitch = myo.getPitch()
		local roll = myo.getRoll()
		if pose == "waveIn" then
			if roll > PI/4 then
				firstslide()
			elseif roll < -PI/4 then
				lastslide()
			else
				shuttleDirection = "forward"
				shuttleBurst()
			end
		elseif pose == "waveOut" then
			shuttleDirection = "backward"
			shuttleBurst()
		elseif pose == "fingersSpread" and pitch > PI/4 then
			enterFullscreen()
		elseif pose == "fist" and pitch > PI/4 then
			exitFullscreen()
		else
			return 0
		end
		
		-- small vibration to notify the user
		myo.notifyUserAction()
		
	end
  
end

