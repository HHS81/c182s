##########################################
#
# Aircraft states
#
# This script provides functions to get the aircraft into a defined state.
# The idea is that the checklist-states define states of the plane after conducting the checklist.
# Common functions are centralized in specific functions.
# The autostart- and state-functions then provide "bundles" of those checklists and override items if needed.
#
# The initial state can be overwritten by command line by adding for example: "--state=cruising"
# Setting the initial state like this is not persistet after quit.
#
# Author: B. Hallinger 2017/2018
##########################################


# The supported states in state property
var state_property   = "/sim/start-state"; #saved state
var init_env_state   = "/sim/aircraft-state"; #state from launcher/cmd-line


####################
# Common helpers   #
####################
var setAvionics = func(state) {
    setprop("/controls/switches/AVMBus1", state);  
    setprop("/controls/switches/AVMBus2", state);
    setprop("/instrumentation/audio-panel/power-btn", state);
    setprop("/instrumentation/audio-panel/volume-ics-pilot", state);
    setprop("/controls/switches/kt-76c", state * 4);
    setprop("/controls/switches/kn-62a", state);
    setprop("/instrumentation/nav[0]/power-btn", state);
    setprop("/instrumentation/nav[1]/power-btn", state);
    setprop("/instrumentation/comm[0]/volume-selected", state);
    setprop("/instrumentation/comm[1]/volume-selected", state);
    setprop("/controls/switches/kn-62a", state);
    setprop("/instrumentation/adf[0]/power-btn", state);
}

var secureAircraftOnGround = func(state) {
    # Secure on ground, but wait for after init time to avoid "the weird aircraft dance"
    var t = getprop("/sim/time/elapsed-sec") or 0;
    if (t <= 0.30) {
        # recall sometime later in case sim just started
        settimer(func(){ secureAircraftOnGround(state);}, 0.30);
        return;
    }
    
    if (getprop("/sim/chocks001/enable") != state) setprop("/sim/chocks001/enable", state);
    if (getprop("/sim/chocks002/enable") != state) setprop("/sim/chocks002/enable", state);
    if (getprop("/sim/chocks003/enable") != state) setprop("/sim/chocks003/enable", state);
    setprop("/sim/model/c182s/securing/pitot-cover-visible", state);
    setprop("/sim/model/c182s/securing/tiedownL-visible", state);
    setprop("/sim/model/c182s/securing/tiedownR-visible", state);
    setprop("/sim/model/c182s/securing/tiedownT-visible", state);
    setprop("/sim/model/c182s/securing/windGustLockPlate-visible", state);
}

######
# Function to start engine
#   rpm:     initial RPM of propeller
#   thottle: desired throttle setting after start
#   mix:     desired mixtrue setting after start
#   prop:    desired propeller setting after start
######
var setEngineRunning = func(rpm, throttle, mix, prop) {

    # Do not engage if autostart already running
    if (getprop("/engines/engine/auto-start")) {
        print("setEngineRunning: skip execution (another instance is already running)");
        return;
    }
    # Do not engage if engine is already on
    if (getprop("/fdm/jsbsim/propulsion/engine/set-running")) {
        print("setEngineRunning: skip execution (another instance is already running)");
        return;
    }
    
    setprop("/engines/engine/auto-start", 1);

    #
    # Prestart preparations
    #
    
    repair_damage();
    reset_fuel_contamination();
    
    # Remove preheater in case it was attached
    setprop("/engines/engine/external-heat/enabled", 0);
    
    # Battery/Alternator on
    setprop("/controls/engines/engine[0]/master-bat", 1);
    setprop("/controls/engines/engine[0]/master-alt", 1);

    # Avionics off for start, will be restored after start
    var ams1_old = getprop("/controls/switches/AVMBus1");
    var ams2_old = getprop("/controls/switches/AVMBus2");
    setprop("/controls/switches/AVMBus1", 0);  
    setprop("/controls/switches/AVMBus2", 0);
    
    # Essential lever and switch positions
    setprop("/controls/engines/engine/magnetos", 3);
    setprop("/controls/engines/engine[0]/throttle", 0.2);
    setprop("/controls/engines/engine[0]/mixture", getprop("/controls/engines/engine/mixture-maxaltitude"));
    setprop("/controls/engines/engine[0]/propeller-pitch", 1);
    
    
    
    #
    # Engine start function
    #
    
    # Ensure disabled complex-engine-procedures
    # (so engine always starts)
    var complexEngineProcedures_state_old = getprop("/engines/engine/complex-engine-procedures");
    setprop("/engines/engine/complex-engine-procedures", 0);

    # All set, starting engine
    setprop("/controls/switches/starter", 1);
    # Instant-on does not work currently... but would be preferable!
    #setprop("/consumables/fuel/tank[5]/level-gal_us", 0.5);
    #setprop("/fdm/jsbsim/propulsion/tank[5]/pct-full", 0.5);
    #setprop("/fdm/jsbsim/propulsion/tank[5]/priority", 1);
    #setprop("/fdm/jsbsim/running", 1);
    #setprop("/fdm/jsbsim/propulsion/engine/set-running", 1);
    #setprop("/engines/engine/rpm", rpm);
    #setprop("/engines/engine/running", 1);

    var engine_running_check_delay = 3.0;
    settimer(func {
        setprop("/controls/switches/starter", 0);
        
        # Reset complex-engine-procedures user setting
        setprop("/engines/engine/complex-engine-procedures", complexEngineProcedures_state_old);
        
        setprop("/controls/switches/AVMBus1", ams1_old);  
        setprop("/controls/switches/AVMBus2", ams2_old);
        
        # apply desired after-start properties
        if (getprop("/engines/engine/auto-start")) {
            # slowly for autostart
            interpolate("/controls/engines/engine[0]/throttle", throttle, 3);
            interpolate("/controls/engines/engine[0]/mixture", mix, 3);
            interpolate("/controls/engines/engine[0]/propeller-pitch", prop, 3);
        } else {
            # instant for presets/states
            setprop("/controls/engines/engine[0]/throttle", throttle);
            setprop("/controls/engines/engine[0]/mixture", mix);
            setprop("/controls/engines/engine[0]/propeller-pitch", prop);
        }
        
        # all done, go home
        setprop("/engines/engine/auto-start", 0);
        
    }, engine_running_check_delay);

};


####################
# Function fast-boots kap140
# (skip PFT checks etc)
####################
var kap140_fastboot = func() {
        print("Apply state: fast-booting autopilot");
        setprop("/autopilot/kap140/panel/state", 5);
        setprop("/autopilot/kap140/panel/old-state", 5);
        setprop("/autopilot/kap140/panel/pft-1", getprop("sim/time/elapsed-sec"));
        setprop("/autopilot/kap140/panel/pft-2", getprop("sim/time/elapsed-sec"));
        setprop("/autopilot/kap140/panel/pft-3", getprop("sim/time/elapsed-sec"));
        setprop("autopilot/kap140/servo/roll-servo/check-timer", -1);
        setprop("autopilot/kap140/servo/pitch-servo/check-timer", -1);
        setprop("/instrumentation/altimeter-kap140-internal/setting-inhg", getprop("instrumentation/altimeter/setting-inhg"));
};


####################
# Checklist states #
####################
var checklist_afterLanding = func() {
    setprop("/controls/flight/flaps", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
}

var checklist_secureAircraft = func() {
    setprop("/controls/gear/brake-parking", 1);
    setprop("/controls/engines/engine[0]/throttle", 0.0);
    setprop("/controls/lighting/nav-lights", 0);
    setprop("/controls/lighting/strobe", 0);
    setprop("/controls/lighting/beacon", 0);
    setprop("/controls/lighting/taxi-light", 0);
    setprop("/controls/lighting/landing-light", 0);
    setprop("/controls/lighting/beacon", 0);
    setAvionics(0);
    setprop("/controls/engines/engine[0]/mixture", 0.0);
    setprop("/controls/switches/starter", 0);
    setprop("/controls/switches/magnetos", 0);
    setprop("/controls/engines/engine[0]/master-bat", 0);
    setprop("/controls/engines/engine[0]/master-alt", 0);
    setprop("/sim/model/c182s/cockpit/control-lock-placed", 1);
    setprop("/controls/switches/fuel_tank_selector", 1);
}
        
var checklist_preflight = func() {
    reset_fuel_contamination();
    
    # Checking for minimal oil level
    var oil_level = getprop("/engines/engine/oil-level");
    if (oil_level < 6) {
        setprop("/engines/engine/oil-level", 8.0);
    }

    # Checking for minimal fuel level
    var fuel_level_left  = getprop("/consumables/fuel/tank[0]/level-norm");
    var fuel_level_right = getprop("/consumables/fuel/tank[1]/level-norm");
    if (fuel_level_left < 0.25)
        setprop("/consumables/fuel/tank[0]/level-norm", 0.25);
    if (fuel_level_right < 0.25)
        setprop("/consumables/fuel/tank[1]/level-norm", 0.25);
    
    setprop("/sim/model/c182s/cockpit/control-lock-placed", 0);
    setprop("/controls/gear/brake-parking", 1);
    setprop("/systems/static-selected-source", 0);
    secureAircraftOnGround(0);
}

var checklist_beforeEngineStart = func() {
    # Setting levers and switches for startup
    setprop("/controls/switches/fuel_tank_selector", 2);
    setprop("/controls/switches/magnetos", 3);
    setprop("/controls/engines/engine[0]/throttle", 0.2);
    setprop("/controls/engines/engine[0]/mixture", getprop("/controls/engines/engine/mixture-maxaltitude"));
    setprop("/controls/engines/engine[0]/propeller-pitch", 1);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
    setprop("/controls/engines/engine[0]/fuel-pump", 0);
    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/flight/rudder-trim", 0.0);
    setprop("/controls/engines/engine[0]/master-bat", 1);
    setprop("/controls/engines/engine[0]/master-alt", 1);

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
    
    # close doors
    DoorL.close();
    DoorR.close();
    BaggageDoor.close();
    # may remain open: WindowL.close();
    # may remain open: WindowR.close();

    # Adjust winterkit depending on OAT
    # (we must do this with delay on sim sart to give the weather system a chance to adjust temperature at startup)
    var wkdelay =  getprop("/sim/time/elapsed-sec") > 1 ? 0.5 : 5;
    settimer(func {
        var wk_install = getprop("/environment/temperature-degf") > 20? 0 : 1;
        setprop("/engines/engine/winter-kit-installed", wk_install);
    }, wkdelay);

}




####################
# State settings   #
####################

var state_saved = func() {
    # Basically: do nothing, flightgear already has initialized everything from the savefile
};

var state_coldAndDark = func() {
    repair_damage();
    checklist_afterLanding();
    checklist_secureAircraft();
    secureAircraftOnGround(1);
    
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
    
    # lights off
    setprop("/controls/lighting/dome-light-r", 0);
    setprop("/controls/lighting/dome-light-l", 0);
    setprop("/controls/lighting/dome-exterior-light", 0);
    setprop("/controls/lighting/instrument-lights-norm", 0);
    setprop("/controls/lighting/glareshield-lights-norm", 0);
    setprop("/controls/lighting/pedestal-lights-norm", 0);
    setprop("/controls/lighting/radio-lights-norm", 0);
    
    setprop("/controls/switches/magnetos", 0);
};

var state_readyForTakeoff = func() {
    repair_damage();
    reset_fuel_contamination();
    secureAircraftOnGround(0);
    checklist_beforeEngineStart();
    setAvionics(1);
    setEngineRunning(1000, 0.1, getprop("/controls/engines/engine/mixture-maxaltitude"), 1);
    setprop("/controls/gear/brake-parking", 1);
    setprop("/controls/engines/engine/cowl-flaps-norm", 1);
    
    var ap_start_delay = 3.5;
    settimer(kap140_fastboot, ap_start_delay);
};

var state_cruising = func() {
    repair_damage();
    reset_fuel_contamination();
    secureAircraftOnGround(0);
    checklist_beforeEngineStart();
    setAvionics(1);
    setEngineRunning(2000, 0.75, 0.7, getprop("/controls/engines/engine/mixture-maxaltitude-lean"));
    setprop("/controls/gear/brake-parking", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 0);
    
    var ap_start_delay = 3.5;
    settimer(kap140_fastboot, ap_start_delay);
}

var state_approach = func() {
    # lower initial airspeed is set from state-overlay xml
    repair_damage();
    reset_fuel_contamination();
    secureAircraftOnGround(0);
    checklist_beforeEngineStart();
    setAvionics(1);
    setprop("/controls/lighting/landing-lights", 1);
    setEngineRunning(2400, 0.50, 1.0, 1.00);
    setprop("/controls/gear/brake-parking", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 0);
    
    var ap_start_delay = 3.5;
    settimer(kap140_fastboot, ap_start_delay);
}

# Add some oil and cht temp override to simulate an engine that had already run for some time
# Note: the values depend significantly on OAT and the current engine configuration.
#       we might consider to make the adjustments depending on that to get better results, but for now,
#       the goal is to have sensible starting values for the state system when crusing/approach/ready-for-takeoff,
#       ie. to not trigger the "oil too cold" engine roughness and coughing.
var state_adjustEngineTemps = func(oilTemp, chtTemp) {
    setprop("/engines/engine/oil-temperature-degf-offset", oilTemp);
    interpolate("/engines/engine/oil-temperature-degf-offset", 0, 100);
    
    setprop("/engines/engine/cht-temperature-degf-offset", chtTemp);
    interpolate("/engines/engine/cht-temperature-degf-offset", 0, 40);
}


##########################################
# Apply selected state
##########################################
var applyAircraftState = func() {
    var selected_state = getprop(state_property);
    
    # see if saved state-setting is overridden by "--state"-setting (overlay)
    var init_state = getprop(init_env_state);
    if (init_state) {
        print("Apply state: overridden state (" ~ selected_state ~ ") by commandline (" ~ init_state ~ ")");
        setprop(init_env_state, ""); # overwrite internal value, so consecutive "apply"-calls (->gui!) will use prio-user value
        selected_state = init_state;
    }
    
    if (selected_state == "auto") {
        # get from presets
        var prs_onground = getprop("/sim/presets/onground") or "";
        var prs_parkpos  = getprop("/sim/presets/parkpos") or "";
        var prs_rwy      = getprop("/sim/presets/runway") or "";
        
        if (prs_onground) {
            # either parking or runway/taxi/elsewhere
            if (prs_parkpos != "") {
                # currently has a bug with parkpos name "0" because this gets initialized to "" by fgfs
                print("Apply state: Automatic (parking->ColdAndDark)");
                state_coldAndDark();
            } else {
                print("Apply state: Automatic (not-parking->ReadyForTakeoff)");
                state_readyForTakeoff();
                if (getprop("/sim/time/elapsed-sec") <= 10) state_adjustEngineTemps(100, 225);
            }
        } else {
            # somewhere in the air
            print("Apply state: Automatic (in-air->cruise)");
            state_cruising();
            if (getprop("/sim/time/elapsed-sec") <= 10) state_adjustEngineTemps(130, 275);
        }
    }
    if (selected_state == "saved") {
        # saved state
        print("Apply state: saved");
        state_saved();
    }
    if (selected_state == "parking") {
        print("Apply state: Cold-and-Dark");
        state_coldAndDark();
    }
    if (selected_state == "take-off") {
        print("Apply state: Ready-for-Takeoff");
        state_readyForTakeoff();
        if (getprop("/sim/time/elapsed-sec") <= 10) state_adjustEngineTemps(100, 225);
    }
    if (selected_state == "cruise") {
        print("Apply state: cruise");
        state_cruising();
        if (getprop("/sim/time/elapsed-sec") <= 10) state_adjustEngineTemps(130, 275);
    }
    if (selected_state == "approach") {
        print("Apply state: approach");
        state_approach();
        if (getprop("/sim/time/elapsed-sec") <= 10) state_adjustEngineTemps(130, 275);
    }
};



##########################################
# Autostart (to be called by GUI option)
#  Parameters:
#   - msg          Print gui messages
#   - delay        seconds for delay of start
#   - setStates    for invocation by init-states
##########################################
var autostart = func (msg=1, delay=1, setStates=0) {
    print("Autostart engine engaged.");
    var altAGL = getprop("/position/altitude-agl-ft");
    var onGround = 0; if (altAGL <= 5) onGround = 1;

    if (getprop("/fdm/jsbsim/propulsion/engine/set-running") and !setStates) {
        # When engine already running, perform autoshutdown
        if (msg)
            gui.popupTip("Autoshutdown engine engaged.", 5);
                
        #After landing
        checklist_afterLanding();
        
        # Shutdown engine
        setprop("/controls/engines/engine[0]/throttle", 0.0);
        setprop("/controls/engines/engine[0]/mixture", 0.0);
        setprop("/controls/switches/starter", 0);
        setprop("/controls/switches/magnetos", 0);

        var securingDelay = 3;
        settimer(func {
            # Securing only if on ground
            if (onGround) {
                #Securing Aircraft
                checklist_secureAircraft();
                
                #securing Aircraft on ground
                secureAircraftOnGround(1);
            }
            
            print("Autoshutdown engine complete.");
        }, securingDelay);
        
        return;
    }
    
    # Repair Aircraft
    # This repairs any damage, reloads battery, removes water contamination, etc
    repair_damage();
    reset_fuel_contamination();

    # Pre-flight inspection
    checklist_preflight();
    
    # Before start checklist
    checklist_beforeEngineStart();
    
    # Avionics should be on after start
    setAvionics(1); #will be disabled by enigneStart function
    
    # kick off engine
    var delay = 1;
    settimer(func {
        var throttle = 0.15; if (!onGround) throttle = 0.75;
        var rpm      = 2400;
        var mixture  = getprop("/controls/engines/engine/mixture-maxaltitude-lean");
        var prop     = 1.0;
        print("Autostart engine: execute setEngineRunning");
        print("  RPM:      "~rpm);
        print("  Throttle: "~throttle);
        print("  Prop:     "~prop);
        print("  Mixture:  "~mixture);
        #state_adjustEngineTemps(75,75);  #! not calling on purpose! Autostart should only try to start the engine, not suceed in all cases!
        setEngineRunning(rpm, throttle, mixture, prop);
         
        # investigate results once starter is done
        var startListener = setlistener("/engines/engine/auto-start", func(n){
            if (n.getValue() == 0) {
                
                # activate avionics
                setAvionics(1);
                
                # report results after some more time
                reportResults = maketimer(2, func{
                    if (!getprop("/fdm/jsbsim/propulsion/engine/set-running")) {
                        var failMsg = "The autostart failed to start the engine.";
                        
                        if (getprop("/engines/engine/complex-engine-procedures")) {
                            failMsg = failMsg~"\nTry preheating or disabling 'complex engine procedures'";
                        } else {
                            failMsg = failMsg~"\nTry leaning and starting manually'";
                        }
                            
                        gui.popupTip(failMsg, 5);
                        print("Autostart engine FAILED");
                        print("  oil temp °F: "~getprop("/engines/engine/oil-final-temperature-degf"));
                        print("  complex-engine-procedures: "~getprop("/engines/engine/complex-engine-procedures"));
                    } else {
                        print("Autostart engine succeeded.");
                    }
                });
                reportResults.singleShot = 1;
                reportResults.start();
                
                removelistener(startListener);
                
            }
        });
                 
    }, delay);
    

};


# Translates GUI selection strings to /sim/start-state
var updateStateSettingGUI = func() {
    var selection_prop    = "/sim/start-state-internal/gui-selection";
    var selectionkey_prop = "/sim/start-state-internal/gui-selection-key";
    var translations = {
        "auto":     ["Automatic"],
        "saved":    ["Saved state"],
        "parking":  ["Cold and Dark"],
        "take-off": ["Ready for Takeoff"],
        "cruise":   ["Cruising"],
        "approach": ["Approach"],
    };
    
    # init drop down if not set already
    var state_current  = getprop(state_property);
    var state_selected = getprop(selection_prop);
    if (state_selected == nil or state_selected == "") {
        state_selected     = "Automatic";
        state_selected_key = "auto";
        foreach(var trans_key; keys(translations)) {
            if (trans_key == state_current) {
                var trans_list = translations[trans_key];
                state_selected     = trans_list[0];
                state_selected_key = trans_key;
                break;
            }
        }
        setprop(selection_prop, state_selected);
        setprop(selectionkey_prop, state_selected_key);
    }
    
    # Set start state property based on translation
    var state_new = "";
    foreach(var trans_key; keys(translations)) {
        var trans_list = translations[trans_key];
        foreach(var t; trans_list) {
            if (t == state_selected) {
                state_new = trans_key;
                break;
            }
        }
        if (state_new != "") break;
    }
    if (state_new == "") state_new = "auto";
    setprop(state_property, state_new);
}



####################
# INIT STATE
####################

updateStateSettingGUI();

# init airspeed if in-air and KIAS not requested otherwise by preset
if (!getprop("/sim/presets/onground") and !getprop("/sim/presets/airspeed-kt")) {
    setprop("/sim/presets/airspeed-kt", 100);
}

setlistener("/sim/signals/fdm-initialized", func {
    # Apply selected state
    settimer(applyAircraftState, 0.5); # runs myFunc after n-seconds
});
