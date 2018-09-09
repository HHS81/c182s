###############################################################################
##
## Davtron 803
##
##  Original from Nasal for DR400-dauphin by dany93;
##                    Clément de l'Hamaide - PAF Team - http://equipe-flightgear.forumactif.com
##  Heavily modified in 2017 for c182s by Benedikt Hallinger
##  
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################


##########################################
# Flight timer / Elapsed timer
# Note: Currently only counting upwards is supported; whilst the device also supports count down mode!
##########################################


# Floor function
var floor = func(v) v < 0.0 ? -int(-v) - 1 : int(v);

# Time format function: Format time of property from secs to HH:MM format
var timeFormat = func(timeProp){

  elapsedTime = getprop(timeProp);

  hrs = floor(elapsedTime/3600);
  min = floor(elapsedTime/60);
  sec = elapsedTime;

  if (elapsedTime > 3599) {
    # Display HH:MM after 59:59 minute/ timer
    formattedTime = sprintf("%02d:%02d", hrs, min-(60*hrs));
  } else {
    formattedTime = sprintf("%02d:%02d", min, sec-(60*min));
  }
  
  return formattedTime;
}


# Called from Action binding when Control button is pressed
var controlButtonPressed = func {
    # Get the clock mode
    clock_mode = getprop("/instrumentation/davtron803/bot-mode");
    
    if (clock_mode == "FT") {
        # just note when the button was pressed
        controlBtnPressedAt = getprop("/sim/time/elapsed-sec"); 
    }
    
    if (clock_mode == "ET") {
        # handle ET timer: control cycles start->stop->reset
        if (!davtron_elapsed_time.running) {
            if (!elapsedTimeResetMarker) {
                davtron_elapsed_time.start();
            } else {
                davtron_elapsed_time.reset();
                elapsedTimeResetMarker = 0;
            }
        } else {
            davtron_elapsed_time.stop();
            elapsedTimeResetMarker = 1;
        }
    }

}

# Called from Action binding when Control button is released
var controlButtonReleased = func {
    clock_mode = getprop("/instrumentation/davtron803/bot-mode");
    
    if (clock_mode == "FT") {
        # reset FT only if pressed longer than 3 secs
        elapsedSimTime = getprop("/sim/time/elapsed-sec");
        if (controlBtnPressedAt+3 <= elapsedSimTime) {
            davtron_flight_time.reset();
        }
        controlBtnPressedAt = 0;
    }
    
}


###########
# INIT
###########

# init state
controlBtnPressedAt = 0;
elapsedTimeResetMarker = 0;

# init timers (API details: http://api-docs.freeflightsim.org/fgdata/aircraft_8nas_source.html )
props.globals.initNode("/instrumentation/davtron803/flight-time-secs",  0, "INT");
props.globals.initNode("/instrumentation/davtron803/elapsed-time-secs", 0, "INT");
var davtron_flight_time  = aircraft.timer.new("/instrumentation/davtron803/flight-time-secs", 1, 0);
var davtron_elapsed_time = aircraft.timer.new("/instrumentation/davtron803/elapsed-time-secs", 1, 0);

# Activate the FT timer at startup of elec system
# and stop if no power registered (note, the ET timer seems to count on as seen in real life. FT timer behavior is not verified in this way and may be wrong)
setlistener("/systems/electrical/volts", func(clocknode) {
    if (clocknode.getValue() > 1) {
        davtron_flight_time.start();
    } else {
        davtron_flight_time.stop();
    }
}, 1, 0);

# Generate formatted output in separate properties
timeFormatUpdateLoop = maketimer(1, func(){
            setprop("/instrumentation/davtron803/flight-time", timeFormat("/instrumentation/davtron803/flight-time-secs"));
            setprop("/instrumentation/davtron803/elapsed-time", timeFormat("/instrumentation/davtron803/elapsed-time-secs"));
        });
timeFormatUpdateLoop.start();

print("Davtron 803 initialized");
