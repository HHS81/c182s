##########################################
#
# Aircraft states
#
# This script provides functions to get the aircraft in a defined state.
##########################################



var coldAndDark = func() {
    setprop("/controls/flight/flaps", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
    setprop("/controls/gear/brake-parking", 1);
    setprop("/controls/engines/engine[0]/throttle", 0.0);
    setprop("/controls/lighting/nav-lights", 0);
    setprop("/controls/lighting/strobe", 0);
    setprop("/controls/lighting/beacon", 0);
    setprop("/controls/switches/AVMBus1", 0);  
    setprop("/controls/switches/AVMBus2", 0);  
    setprop("/controls/engines/engine[0]/mixture-lever", 0.0);
    setprop("/controls/switches/starter", 0);
    setprop("/controls/engines/engine[0]/magnetos", 0);
    setprop("/controls/engines/engine[0]/master-bat", 0);
    setprop("/controls/engines/engine[0]/master-alt", 0);
    setprop("/sim/model/c182s/cockpit/control-lock-placed", 1);
    setprop("/controls/switches/fuel_tank_selector", 1);
    
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
    
    # lights
    setprop("/controls/lighting/dome-light-r", 0);
    setprop("/controls/lighting/dome-light-l", 0);
    setprop("/controls/lighting/dome-exterior-light", 0);
    setprop("/controls/lighting/instrument-lights-norm", 0);
    setprop("/controls/lighting/glareshield-lights-norm", 0);
    setprop("/controls/lighting/pedestal-lights-norm", 0);
    setprop("/controls/lighting/radio-lights-norm", 0);
    
    # avionics
    setprop("/instrumentation/audio-panel/power-btn", 0);
    setprop("/instrumentation/audio-panel/volume-ics-pilot", 0);
    setprop("/controls/switches/kt-76c", 0);
    setprop("/controls/switches/kn-62a", 0);
    setprop("/instrumentation/nav[0]/power-btn", 0);
    setprop("/instrumentation/nav[1]/power-btn", 0);
    setprop("/instrumentation/comm[0]/power-btn", 0);
    setprop("/instrumentation/comm[1]/power-btn", 0);
    setprop("/instrumentation/comm[0]/volume-selected", 0);
    setprop("/instrumentation/comm[1]/volume-selected", 0);
    setprop("/controls/switches/kn-62a-mode", 0);
    setprop("/instrumentation/adf[0]/power-btn", 0);
    
    setprop("/sim/start-state-internal/oil-temp-override", 0);
};

var engineRunning = func(rpm, throttle, mix, prop) {
    repair_damage();
    setprop("/controls/flight/flaps", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
    setprop("/controls/gear/brake-parking", 1);
    setprop("/controls/lighting/nav-lights", 1);
    setprop("/controls/lighting/strobe", 1);
    setprop("/controls/lighting/beacon", 1);
    setprop("/controls/switches/AVMBus1", 1);  
    setprop("/controls/switches/AVMBus2", 1);
    setprop("/controls/switches/starter", 0);
    setprop("/controls/engines/engine[0]/magnetos", 3);
    setprop("/controls/engines/engine[0]/master-bat", 1);
    setprop("/controls/engines/engine[0]/master-alt", 1);
    setprop("/sim/model/c182s/cockpit/control-lock-placed", 0);
    setprop("/controls/switches/fuel_tank_selector", 2);
    
    #let engine run
    setprop("/sim/start-state-internal/oil-temp-override", 1); # override disables coughing due to low oil temp
    settimer(func{ setprop("/sim/start-state-internal/oil-temp-override", 0); }, 240); # disable override after this time
    autostart(0, 0, 1);
    setprop("/controls/engines/engine[0]/throttle", throttle);
    setprop("/controls/engines/engine[0]/mixture-lever", mix);
    setprop("/controls/engines/engine[0]/propeller-pitch", prop);
    setprop("/controls/switches/AVMBus1", 1);
    setprop("/controls/switches/AVMBus2", 1);
    
    # Instant-on does not work currently... but would be preferable!
    #setprop("/consumables/fuel/tank[5]/level-gal_us", 0.5);
    #setprop("/fdm/jsbsim/propulsion/tank[5]/pct-full", 0.5);
    #setprop("/fdm/jsbsim/propulsion/tank[5]/priority", 1);
    #setprop("/fdm/jsbsim/running", 1);
    #setprop("/fdm/jsbsim/propulsion/engine/set-running", 1);
    #setprop("/engines/engine[0]/rpm", rpm);
    #setprop("/engines/engine[0]/running", 1);
    
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
    
    # Avionics ON
    setprop("/instrumentation/audio-panel/power-btn", 1);
    setprop("/instrumentation/audio-panel/volume-ics-pilot", 1);
    setprop("/controls/switches/kt-76c", 1);
    setprop("/controls/switches/kn-62a", 1);

    setprop("/instrumentation/nav[0]/power-btn", 1);
    setprop("/instrumentation/nav[1]/power-btn", 1);
    setprop("/instrumentation/comm[0]/power-btn", 1);
    setprop("/instrumentation/comm[1]/power-btn", 1);
    setprop("/instrumentation/comm[0]/volume-selected", 1);
    setprop("/instrumentation/comm[1]/volume-selected", 1);
    setprop("/controls/switches/kn-62a-mode", 1);
    setprop("/instrumentation/adf[0]/power-btn", 1);
};


##########################################
# Apply selected state
##########################################
var applyAircraftState = func() {
    var stateSaved  = getprop("/sim/start-state_saved") or 0;
    var stateCnD    = getprop("/sim/start-state_CnD") or 0;
    var stateRfT    = getprop("/sim/start-state_RfT") or 0;
    var stateCruise = getprop("/sim/start-state_Crs") or 0;
    
    if (stateSaved == 1) {
        # do nothing, flightgear already has initialized
        print("Apply state: saved");
    }
    if (stateCnD == 1) {
        print("Apply state: Cold-and-Dark");
        coldAndDark();
    }
    if (stateRfT == 1) {
        print("Apply state: Ready-for-Takeoff");
        engineRunning(1000, 0.1, 1, 1);
    }
    if (stateCruise == 1) {
        print("Apply state: cruise");
        engineRunning(2000, 1, 0.9, 0.80);  # TODO: Mix should be calculated by altitude
        setprop("/controls/gear/brake-parking", 0);
    }
};



##########################################
# Autostart
#  Parameters:
#   - msg          Print gui messages
#   - delay        seconds for delay of start
#   - setStates    for invocation by init-states
##########################################
var autostart = func (msg=1, delay=1, setStates=0) {
    print("Autostart engine engaged.");
    if (getprop("/fdm/jsbsim/propulsion/engine/set-running") and !setStates) {
        # When engine already running, perform autoshutdown
        if (msg)
            gui.popupTip("Autoshutdown engine engaged.", 5);
                
        #After landing
        setprop("/controls/flight/flaps", 0);
        setprop("/controls/engines/engine/cowl-flaps-norm", 1);

        #Securing Aircraft
        setprop("/controls/gear/brake-parking", 1);
        setprop("/controls/engines/engine[0]/throttle", 0.0);
        setprop("/controls/lighting/nav-lights", 0);
        setprop("/controls/lighting/strobe", 0);
        setprop("/controls/lighting/beacon", 0);
        setprop("/controls/switches/AVMBus1", 0);  
        setprop("/controls/switches/AVMBus2", 0);  
        setprop("/controls/engines/engine[0]/mixture-lever", 0.0);
        setprop("/controls/switches/starter", 0);
        setprop("/controls/engines/engine[0]/magnetos", 0);
        setprop("/controls/engines/engine[0]/master-bat", 0);
        setprop("/controls/engines/engine[0]/master-alt", 0);
        setprop("/sim/model/c182s/cockpit/control-lock-placed", 1);
        setprop("/controls/switches/fuel_tank_selector", 1);
        
        #securing Aircraft on ground
        setprop("/sim/chocks001/enable", 1);
        setprop("/sim/chocks002/enable", 1);
        setprop("/sim/chocks003/enable", 1);
        setprop("/sim/model/c182s/securing/pitot-cover-visible", 1);
        setprop("/sim/model/c182s/securing/tiedownL-visible", 1);
        setprop("/sim/model/c182s/securing/tiedownR-visible", 1);
        setprop("/sim/model/c182s/securing/tiedownT-visible", 1);
        
        print("Autoshutdown engine complete.");
        return;
    }
    
    # Repair Aircraft
    # This repairs any damage, reloads battery, removes water contamination, resets oil, etc
    repair_damage();
    

    # Filling fuel tanks
    setprop("/consumables/fuel/tank[0]/selected", 1);
    setprop("/consumables/fuel/tank[1]/selected", 1);

    # Setting levers and switches for startup
    setprop("/controls/switches/fuel_tank_selector", 2);
    setprop("/controls/engines/engine[0]/magnetos", 3);
    setprop("/controls/engines/engine[0]/throttle", 0.2);
    setprop("/controls/engines/engine[0]/mixture-lever", 1.0);
    setprop("/controls/engines/engine[0]/propeller-pitch", 1);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
    setprop("/controls/engines/engine[0]/fuel-pump", 0);
    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/flight/rudder-trim", 0.0);
    setprop("/controls/engines/engine[0]/master-bat", 1);
    setprop("/controls/engines/engine[0]/master-alt", 1);
    setprop("/controls/switches/AVMBus1", 0);  # off for start
    setprop("/controls/switches/AVMBus2", 0);  # off for start

    # Setting lights
    setprop("/controls/lighting/nav-lights", 1);
    setprop("/controls/lighting/strobe", 1);
    setprop("/controls/lighting/beacon", 1);

    # Setting flaps to 0
    setprop("/controls/flight/flaps", 0.0);

    # Set the altimeter
    var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
    setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

    # Set heading offset
    var magnetic_variation = getprop("/environment/magnetic-variation-deg");
    setprop("/instrumentation/heading-indicator/offset-deg", -magnetic_variation);

    # Pre-flight inspection
    setprop("/sim/model/c182s/cockpit/control-lock-placed", 0);
    setprop("/controls/gear/brake-parking", 1);
    setprop("/sim/chocks001/enable", 0);
    setprop("/sim/chocks002/enable", 0);
    setprop("/sim/chocks003/enable", 0);
    setprop("/sim/model/c182s/securing/pitot-cover-visible", 0);
    setprop("/sim/model/c182s/securing/tiedownL-visible", 0);
    setprop("/sim/model/c182s/securing/tiedownR-visible", 0);
    setprop("/sim/model/c182s/securing/tiedownT-visible", 0);


    # Checking for minimal fuel level
    var fuel_level_left  = getprop("/consumables/fuel/tank[0]/level-norm");
    var fuel_level_right = getprop("/consumables/fuel/tank[1]/level-norm");

    if (fuel_level_left < 0.25)
        setprop("/consumables/fuel/tank[0]/level-norm", 0.25);
    if (fuel_level_right < 0.25)
        setprop("/consumables/fuel/tank[1]/level-norm", 0.25);

    
    # Ensure disabled complex-engine-procedures
    # (so engine always starts)
    var complexEngineProcedures_state_old = getprop("/engines/engine/complex-engine-procedures");
    setprop("/engines/engine/complex-engine-procedures", 0);

    
    
    
    # All set, starting engine
    settimer(func {
        setprop("/controls/switches/starter", 1);
        setprop("/engines/engine[0]/auto-start", 1);
    }, delay);

    var engine_running_check_delay = 6.0;
    settimer(func {
        if (!getprop("/fdm/jsbsim/propulsion/engine/set-running")) {
            gui.popupTip("The autostart failed to start the engine. You must lean the mixture and start the engine manually.", 5);
            print("Autostart engine FAILED");
        }
        setprop("/controls/switches/starter", 0);
        setprop("/engines/engine[0]/auto-start", 0);
        
        # Reset complex-engine-procedures user setting
        setprop("/engines/engine/complex-engine-procedures", complexEngineProcedures_state_old);
        
        
        # Set switches to after-start state
        if (!setStates) {
            setprop("/controls/switches/AVMBus1", 1);
            setprop("/controls/switches/AVMBus2", 1);
        }

	
        
        
        print("Autostart engine complete.");
        
    }, engine_running_check_delay);
    

};




####################
# INIT STATE
####################
setlistener("/sim/signals/fdm-initialized", func {
    if (getprop("/sim/start-state_RfT") == nil) setprop("/sim/start-state_RfT", 1);  #init default
    settimer(applyAircraftState, 0.5); # runs myFunc after 2 seconds
});
