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

  #formattedTime = sprintf("%02d:%02d:%02d", hrs, min-(60*hrs), sec-(60*min));
  formattedTime = sprintf("%02d:%02d", min-(60*hrs), sec-(60*min));
  
  return formattedTime;
}


# Called from Action binding when Control button is pressed
var controlButtonPressed = func {
    # Get the clock mode
    clock_mode = getprop("/instrumentation/davtron803/bot-mode");
    
    if (clock_mode == "FT") {
        # reset flight timer
        davtron_flight_time.reset();
    }
    if (clock_mode == "ET") {
        # reset elapsed timer
        davtron_elapsed_time.reset();
    }

}





###########
# INIT
###########

# init timers (API details: http://api-docs.freeflightsim.org/fgdata/aircraft_8nas_source.html )
props.globals.initNode("/instrumentation/davtron803/flight-time-secs",  0, "INT");
props.globals.initNode("/instrumentation/davtron803/elapsed-time-secs", 0, "INT");
var davtron_flight_time  = aircraft.timer.new("/instrumentation/davtron803/flight-time-secs", 1);
var davtron_elapsed_time = aircraft.timer.new("/instrumentation/davtron803/elapsed-time-secs", 1);

# Activate the timers at startup
davtron_flight_time.start();
davtron_elapsed_time.start();

# Add listeners to update formatted output on each change
setlistener("/instrumentation/davtron803/flight-time-secs", func() {
    setprop("/instrumentation/davtron803/flight-time", timeFormat("/instrumentation/davtron803/flight-time-secs"));
}, 1);
setlistener("/instrumentation/davtron803/flight-time-secs", func() {
    setprop("/instrumentation/davtron803/elapsed-time", timeFormat("/instrumentation/davtron803/elapsed-time-secs"));
}, 1);

print("Davtron 803 initialized");
