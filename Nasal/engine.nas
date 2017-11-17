# Manages the engine
#
# Hobbs meter

# =============================== DEFINITIONS ===========================================

# set the update period

var UPDATE_PERIOD = 0.3;

# =============================== Hobbs meter =======================================

# this property is saved by aircraft.timer
var hobbsmeter_engine= aircraft.timer.new("/sim/time/hobbs/engine", 60, 1);

var init_hobbs_meter = func(index, meter) {
    setlistener("/engines/engine[" ~ index ~ "]/running", func {
        if (getprop("/engines/engine[" ~ index ~ "]/running")) {
            meter.start();
            print("Hobbs system started");
        } else {
            meter.stop();
            print("Hobbs system stopped");
        }
    }, 1, 0);
};

init_hobbs_meter(0, hobbsmeter_engine);

var update_hobbs_meter = func {
    # in seconds
    var hobbs = getprop("/sim/time/hobbs/engine") or 0.0;
    # This uses minutes, for testing
    #hobbs = hobbs / 60.0;
    # in hours
    hobbs = hobbs / 3600.0;
    # tenths of hour
    setprop("/instrumentation/hobbs-meter/digits0", math.mod(int(hobbs * 10), 10));
    # rest of digits
    setprop("/instrumentation/hobbs-meter/digits1", math.mod(int(hobbs), 10));
    setprop("/instrumentation/hobbs-meter/digits2", math.mod(int(hobbs / 10), 10));
    setprop("/instrumentation/hobbs-meter/digits3", math.mod(int(hobbs / 100), 10));
    setprop("/instrumentation/hobbs-meter/digits4", math.mod(int(hobbs / 1000), 10));
};

setlistener("/sim/time/hobbs/engine", update_hobbs_meter, 1, 0);



# ========== engine coughing ======================

var engine_coughing = func(){
    var coughing = getprop("/engines/active-engine/coughing");
    #var running = getprop("/engines/active-engine/running");
    var running = getprop("/fdm/jsbsim/propulsion/engine/set-running");
    var allow_contamination = getprop("/engines/engine/allow-fuel-contamination");
    
    if (coughing and running) {
        # the code below kills the engine and then brings it back to life after 0.25 seconds, simulating a cough
        setprop("/engines/active-engine/kill-engine", 1);
        settimer(func {
            setprop("/engines/active-engine/kill-engine", 0);
        }, 0.25);
    };
    
    # basic value for the delay (interval between consecutive coughs), in case no fuel contamination
    var delay = 2;
    
    # if coughing due to fuel contamination, then cough interval depends on quantity of water
    var water_contamination0 = getprop("/consumables/fuel/tank[0]/water-contamination");
    var water_contamination1 = getprop("/consumables/fuel/tank[1]/water-contamination");
    var water_contamination2 = getprop("/consumables/fuel/tank[2]/water-contamination");
    var water_contamination3 = getprop("/consumables/fuel/tank[3]/water-contamination");
    var total_water_contamination = std.min((water_contamination0 + water_contamination1 + water_contamination2 + water_contamination3), 0.4);
    if (allow_contamination and total_water_contamination > 0) {
        # if contamination is near 0, then interval is between 17 and 20 seconds, but if contamination is near the 
        # engine stopping value of 0.4, then interval falls to around 0.5 and 3.5 seconds
        delay = 3.0 * rand() + 17 - 41.25 * total_water_contamination;
    };
    
    coughing_timer.restart(delay);
    
}

var coughing_timer = maketimer(1, engine_coughing);
coughing_timer.start();
