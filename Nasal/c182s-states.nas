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
var supported_states = ["auto", "saved", "cold-and-dark", "ready-for-takeoff", "cruising"];
var state_property   = "/sim/start-state"; #saved state
var init_env_state   = "/sim/init-state"; #state from launcher/cmd-line


####################
# Common helpers   #
####################
var setAvionics = func(state) {
    setprop("/controls/switches/AVMBus1", state);  
    setprop("/controls/switches/AVMBus2", state);
    setprop("/instrumentation/audio-panel/power-btn", state);
    setprop("/instrumentation/audio-panel/volume-ics-pilot", state);
    setprop("/controls/switches/kt-76c", state);
    setprop("/controls/switches/kn-62a", state);
    setprop("/instrumentation/nav[0]/power-btn", state);
    setprop("/instrumentation/nav[1]/power-btn", state);
    setprop("/instrumentation/comm[0]/volume-selected", state);
    setprop("/instrumentation/comm[1]/volume-selected", state);
    setprop("/controls/switches/kn-62a-mode", state);
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
    
    setprop("/sim/chocks001/enable", state);
    setprop("/sim/chocks002/enable", state);
    setprop("/sim/chocks003/enable", state);
    setprop("/sim/model/c182s/securing/pitot-cover-visible", state);
    setprop("/sim/model/c182s/securing/tiedownL-visible", state);
    setprop("/sim/model/c182s/securing/tiedownR-visible", state);
    setprop("/sim/model/c182s/securing/tiedownT-visible", state);
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
    setprop("/sim/start-state-internal/oil-temp-override", 1); # override disables coughing due to low oil temp
    settimer(func{ setprop("/sim/start-state-internal/oil-temp-override", 0); }, 240); # disable override after this time
    
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
        setprop("/controls/engines/engine[0]/throttle", throttle);
        setprop("/controls/engines/engine[0]/mixture", mix);
        setprop("/controls/engines/engine[0]/propeller-pitch", prop);
        
        # all done, go home
        setprop("/engines/engine/auto-start", 0);
        
    }, engine_running_check_delay);

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
    setAvionics(0);
    setprop("/controls/engines/engine[0]/mixture", 0.0);
    setprop("/controls/switches/starter", 0);
    setprop("/controls/engines/engine[0]/magnetos", 0);
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
    secureAircraftOnGround(0);
}

var checklist_beforeEngineStart = func() {
    # Setting levers and switches for startup
    setprop("/controls/switches/fuel_tank_selector", 2);
    setprop("/controls/engines/engine[0]/magnetos", 3);
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
    
    setprop("/sim/start-state-internal/oil-temp-override", 0);
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
};

var state_cruising = func() {
    repair_damage();
    reset_fuel_contamination();
    secureAircraftOnGround(0);
    checklist_beforeEngineStart();
    setAvionics(1);
    setEngineRunning(2000, 0.75, 0.7, 0.80);  # TODO: Mix should be calculated lean by altitude
    setprop("/controls/gear/brake-parking", 0);
    setprop("/controls/engines/engine/cowl-flaps-norm", 0);
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
            }
        } else {
            # somewhere in the air
            print("Apply state: Automatic (in-air->cruise)");
            state_cruising();
        }
    }
    if (selected_state == "saved") {
        # saved state
        print("Apply state: saved");
        state_saved();
    }
    if (selected_state == "cold-and-dark") {
        print("Apply state: Cold-and-Dark");
        state_coldAndDark();
    }
    if (selected_state == "ready-for-takeoff") {
        print("Apply state: Ready-for-Takeoff");
        state_readyForTakeoff();
    }
    if (selected_state == "cruising") {
        print("Apply state: cruise");
        state_cruising();
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

        #Securing Aircraft
        checklist_secureAircraft();
        
        #securing Aircraft on ground
        secureAircraftOnGround(1);
        
        print("Autoshutdown engine complete.");
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
        print("Autostart engine: execute setEngineRunning");
        setEngineRunning(2400, 0.05, getprop("/controls/engines/engine/mixture-maxaltitude"), 1.0);
         
        # investigate results once starter is done
        var startListener = setlistener("/engines/engine/auto-start", func(n){
            if (n.getValue() == 0) {
                # autostart has finished
                if (!getprop("/fdm/jsbsim/propulsion/engine/set-running")) {
                    gui.popupTip("The autostart failed to start the engine. You must lean the mixture and start the engine manually.", 5);
                    print("Autostart engine FAILED");
                } else {
                    print("Autostart engine finished.");
                }
                
                # activate avionics
                setAvionics(1);
                
                removelistener(startListener);
                
            }
        });
                 
    }, delay);
    

};


# Updates GUI radio buttons and ensure valid selection
var updateStateSettingGUI = func() {
    var default_state    = "auto";

    var state_valid    = 0;
    var state_selected = getprop(state_property) or "";
    foreach(s; supported_states) {
        var radio_propname = "/sim/start-state-internal/gui-radio-" ~ s;
        if (s == state_selected) {
            setprop(radio_propname, 1);
            state_valid = 1;
        } else {
            setprop(radio_propname, 0);
        }
    };
    
    if (!state_valid) {
        # requested state did not map to a valid selection
        print("INFO: wrong state '" ~ state_selected ~ "' requested, using '" ~ default_state ~ "'");
        setprop("/sim/start-state-internal/gui-radio-" ~ default_state, 1);
        setprop(state_property, default_state);
    }
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
