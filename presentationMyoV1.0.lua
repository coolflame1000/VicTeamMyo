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

myo.debug("debug")

PI = 3.1416
TWOPI = PI * 2

centreYaw = 0  
centreRoll = 0
centrePitch = 0 

YAW_DEADZONE = .1  
ROLL_DEADZONE = .2  
PITCH_DEADZONE = .4

rollleftright = false
moveleftright = false

printCount = 0

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
	myo.keyboard("f5","press")
end

function exitFullscreen()
	myo.keyboard("escape", "press")
end

-- Called every 10 milliseconds, as long as the script is active.
function onPeriodic()

	if (centreYaw == 0) then
		return
	end
	
	local currentYaw = myo.getYaw()
	local currentRoll = myo.getRoll()
	local currentPitch = myo.getPitch()
	
	local deltaYaw = calculateDeltaRadians(currentYaw, centreYaw)
	local deltaRoll = calculateDeltaRadians(currentRoll, centreRoll)
	local deltaPitch = calculateDeltaRadians(currentPitch, centrePitch)
	
	-- debug every 200 events
	printCount = printCount + 1
	if printCount >= 200 then
		myo.debug("deltaYaw = " .. deltaYaw .. ", centreYaw = " .. centreYaw .. ", currentYaw = " .. currentYaw)
		myo.debug("deltaRoll = " .. deltaRoll .. ", centreRoll = " .. centreRoll .. " currentRoll = " .. currentRoll)
		myo.debug("deltaPitch = " .. deltaPitch .. ", centrePitch = " .. centrePitch .. " currentPitch = " .. currentPitch)
		printCount = 0
	end
	
	-- if arm up go to first slide, if arm down go to last slide
	if (deltaPitch > PITCH_DEADZONE) then
		--myo.debug("moving up");
	elseif (deltaPitch < -PITCH_DEADZONE) then
		--myo.debug("moving down");
	end	
	
	
	-- if roll to the left and then to the right move forward
	if (deltaRoll < -ROLL_DEADZONE) then
		--myo.debug("rolling left");
		rollleftright=true
	elseif (deltaRoll > ROLL_DEADZONE) then
		--myo.debug("rolling right");
		if rollleftright==true then
			rollleftright=false
		end	
	end	
	
	-- if move to the left and then to the right move backward
	if (deltaYaw < -YAW_DEADZONE) then
		--myo.debug("moving left");
		moveleftright=true
	elseif (deltaYaw > YAW_DEADZONE) then
		--myo.debug("moving right");
		if moveleftright==true then
			moveleftright=false
		end	
	end	
    
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
		--myo.debug(pose);
		local currentYaw = myo.getYaw()
		local currentRoll = myo.getRoll()
		local currentPitch = myo.getPitch()
		
		local deltaYaw = calculateDeltaRadians(currentYaw, centreYaw)
		local deltaRoll = calculateDeltaRadians(currentRoll, centreRoll)
		local deltaPitch = calculateDeltaRadians(currentPitch, centrePitch)
		
		if (pose == "doubleTap") then
			centre()
		elseif pose == "waveIn" then
			if deltaRoll > 0.18  then
				lastslide()
			elseif deltaRoll < -0.14 then
				firstslide()
			else
				shuttleDirection = "forward"
				shuttleBurst()
			end
		elseif pose == "waveOut" then
			shuttleDirection = "backward"
			shuttleBurst()
		elseif pose == "fingersSpread" and deltaYaw > 0.6 then
			enterFullscreen()
		elseif pose == "fist" and deltaYaw < -0.6 then
			exitFullscreen()
		else
			return 0
		end
		
		-- small vibration to notify the user
		myo.notifyUserAction()
		
	end
  
end

-- ================================= Utility =================================
function calculateDeltaRadians(current, centre)  
	local delta = current - centre

	if (delta > PI) then
		delta = delta - TWOPI
	elseif(delta < -PI) then
		delta = delta + TWOPI
	end
	return delta
end

-- save current position of the arm
function centre()  
	myo.debug("Centred")
	centreYaw = myo.getYaw()
	centreRoll = myo.getRoll()
	centrePitch = myo.getPitch()
	myo.vibrate("short")
end

