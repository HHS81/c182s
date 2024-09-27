##
# Suppplemental floats variant nasal system:
#
# - for the floats gear unit
# - startup state stuff
#




#####################
# Electrical system #
#####################

print("c182s floats nasal electrical system initializing");

##
# Initialize internal values
#
setprop("/systems/electrical/outputs/gear-select", 0.0);
setprop("/systems/electrical/outputs/gear-advisory", 0.0);
setprop("/systems/electrical/outputs/hydraulic-pump", 0.0);
setprop("/sim/model/c182s/hydraulics/hydraulic-pump", 0);

##
# Gear unit wired to master bus
#
var electrical_update_gear_select_volts = func() {
    #print("update gear unit voltage output");
    var volts = getprop("/systems/electrical/volts") or 0.0;
    if (volts > 12 and getprop("controls/circuit-breakers/gear-select")) {
        setprop("/systems/electrical/outputs/gear-select", volts);
    } else {
        setprop("/systems/electrical/outputs/gear-select", 0.0);
    }
    
    if (volts > 12 and getprop("controls/circuit-breakers/gear-advisory")) {
        setprop("/systems/electrical/outputs/gear-advisory", volts);
    } else {
        setprop("/systems/electrical/outputs/gear-advisory", 0.0);
    }
    
    if (volts > 12 and getprop("controls/circuit-breakers/hydraulic-pump")) {
        setprop("/systems/electrical/outputs/hydraulic-pump", volts);
    } else {
        setprop("/systems/electrical/outputs/hydraulic-pump", 0.0);
    }
    
    if (volts > 12) {
        setprop("/sim/model/c182s/hydraulics/hydraulic-pump", 1);
    } else {
        setprop("/sim/model/c182s/hydraulics/hydraulic-pump", 0);
    }
};
setlistener("/systems/electrical/volts", electrical_update_gear_select_volts, 1, 0);
setlistener("controls/circuit-breakers/gear-select",    electrical_update_gear_select_volts, 1, 0);
setlistener("controls/circuit-breakers/gear-advisory",  electrical_update_gear_select_volts, 1, 0);
setlistener("controls/circuit-breakers/hydraulic-pump", electrical_update_gear_select_volts, 1, 0);


# What to do when repairing the plane
setlistener("/fdm/jsbsim/damage/repairing", func(p) {
    if (p.getBoolValue()) {
        setprop("controls/circuit-breakers/gear-select", 1);
        setprop("controls/circuit-breakers/gear-advisory", 1);
        setprop("controls/circuit-breakers/hydraulic-pump", 1);
    }
});
