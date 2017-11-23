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



# ========== oil consumption ======================
var oil_consumption = maketimer(1.0, func {
    var allow_consumption = getprop("/engines/engine/allow-oil-management");

    var oil_level = getprop("/engines/active-engine/oil-level");
    var service_hours = getprop("/engines/active-engine/oil-service-hours");
    var oil_full = 9;
    var oil_lacking = oil_full - oil_level;
    setprop("/engines/active-engine/oil-lacking", oil_lacking);
    
    
    # consume oil if engine is running
    # oil consumption is depending on the time the oil is in service and also on RPM.
    # Consumption also depends on level; above 8 quarts the engine spills some oil
    if (allow_consumption) {
    
        var rpm = getprop("/engines/engine/rpm");
    
        # Consumption according Lycoming manual 3-13:
        # see: https://www.lycoming.com/sites/default/files/O%20%26%20IO-540%20Oper%20Manual%2060297-10.pdf
        #  Standard rated:                  2400 RPM = 0.78 qph
        #  Performance Cruise (75% Rated):  2200 RPM = 0.58 qph
        #  Economy Cruise (60% Rated):      2000 RPM = 0.47 qph
        
        # Formula which outputs basic quarts-per-hour consumption:
        # RPM:   2700 |  2400 |  2200 | 2000  | 800
        # qph:  1.084 | 0.782 | 0.618 | 0.482 | 0.096
        var consumption_qph = 0.0000000000515 * math.pow(rpm, 3) + 0.07;

        # Raise consumption when oil level is > 8 quarts (blowout)
        if (oil_level > 8) {
            consumption_qph = consumption_qph * 1.3;
        }
        
        # Consumption also raises with oil in service time:
        # 0qph at start; about 1qph at 25 and about 3.5qph at 50hrs
        # See: http://www.t-craft.org/Reference/Aircraft.Oil.Usage.pdf
        var service_hours_increase = 0.0013 * math.pow(service_hours, 2);
        if (service_hours_increase > 5) service_hours_increase = 5;  # cap at that rate
        consumption_qph = consumption_qph + service_hours_increase;
    
    
        # Calculate consumption and update properties
        if (getprop("/engines/engine/running")) {
            var consume_oil_qps = consumption_qph / 3600;
            oil_level = oil_level - consume_oil_qps;
            setprop("/engines/active-engine/oil-level", oil_level);
            setprop("/engines/active-engine/oil-consume-qps", consume_oil_qps);
            setprop("/engines/active-engine/oil-consume-qph", consumption_qph);
            
            var service_hours_new = service_hours + 1/3600; # add one second service time
            setprop("/engines/active-engine/oil-service-hours", service_hours_new);
            
            #print("consume oil: ", consumption_rate, "*" , rpm_factor);
            #print("new servcie hours: ", service_hours_new);
        
        } else {
            # engine off
            setprop("/engines/active-engine/oil-consume-qps", 0);
            setprop("/engines/active-engine/oil-consume-qph", 0);
        }

        
        # Calculate pressure and temperature adjustment factors
        var low_oil_pressure_factor = 1.0;
        var low_oil_temperature_factor = 1.0;

        # If oil gets low (< 3.0), pressure should drop and temperature should rise
        var oil_level_limited = std.min(oil_level, 4.0);
    
        # Should give 1.0 for oil_level = 3 and 0.1 for oil_level 1.97,
        # engine.xml defines engine-killing level as 1.97 (POH says, never fly below 4 but contains safety buffer; half that margin is 2)
        low_oil_pressure_factor = 0.873786408 * oil_level_limited - 1.621359224;
        
        # Should give 1.0 for oil_level = 3 and 1.5 for oil_level 1.97
        low_oil_temperature_factor = -0.485436893 * oil_level_limited + 2.456310679;
    
        setprop("/engines/active-engine/low-oil-pressure-factor", low_oil_pressure_factor);
        setprop("/engines/active-engine/low-oil-temperature-factor", low_oil_temperature_factor);
        
        
    } else {
        # consumption disabled
        setprop("/engines/active-engine/low-oil-pressure-factor", 1);
        setprop("/engines/active-engine/low-oil-temperature-factor", 1);
        setprop("/engines/active-engine/oil-consume-qps", 0);
        setprop("/engines/active-engine/oil-consume-qph", 0);
    }

});

# ======== Oil refilling =======
var oil_refill = func(){
    var service_hours = getprop("/engines/active-engine/oil-service-hours");
    var oil_level     = getprop("/engines/active-engine/oil-level");
    var refilled      = oil_level - previous_oil_level;
    #print("OIL Refill init: svcHrs=", service_hours, "; oil_level=",oil_level, "; previous_oil_level=",previous_oil_level, "; refilled=",refilled);
    
    if (refilled >= 0) {
        # when refill occured, the new oil "makes the old oil younger"
        var pct = 0;
        if (oil_level > 0) pct = previous_oil_level / oil_level;
        var newService_hours = service_hours * pct;
        setprop("/engines/active-engine/oil-service-hours", newService_hours);
        #print("OIL Refill: pct=", pct, "; service_hours=",service_hours, "; newService_hours=", newService_hours, "; previous_oil_level=", previous_oil_level, "; oil_level=",oil_level);
    }
    
    previous_oil_level = oil_level;
}


# ======= OIL SYSTEM INIT =======
if (!getprop("/engines/active-engine/oil-level")) {
     setprop("/engines/active-engine/oil-level", 8);
}
var previous_oil_level = getprop("/engines/active-engine/oil-level");
if (!getprop("/engines/active-engine/oil-service-hours")) {
     setprop("/engines/active-engine/oil-service-hours", 0);
}
oil_consumption.start();
