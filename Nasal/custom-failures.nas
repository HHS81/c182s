#
# Extend FailureManager with aircraft specific failure options
#
# see: http://wiki.flightgear.org/A_Failure_Management_Framework_for_FlightGear
# see: https://sourceforge.net/p/flightgear/fgdata/ci/release/2017.3/%7E/tree/Nasal/FailureMgr/public.nas
# see: https://sourceforge.net/p/flightgear/fgdata/ci/release/2017.3/%7E/tree/Aircraft/Generic/Systems/failures.nas
#
# by Benedikt Hallinger, 03/2018
#
#
# /!\ TO DEFINE NEW FAILURES, see customFailures vector below! /!\
#

io.include("Aircraft/Generic/Systems/failures.nas");  #include base compat failure modes (make default triggers (etc) available)




#############################################################################################
# First, some library functions
#

# Update all extended failures, that is: rearm if MCBF/MTBF >0 (or forceRearm is 1), otherwise disable
# (Called from the gui to update the state)
var updateAllExtendedFailures = func(forceRearm=0) {
    foreach (failure; customFailures) {
        var trigger = FailureMgr.get_trigger(failure.id);
        
        # get triggers current internal state
        var typeparam = nil;
        if (trigger.type == "mcbf") typeparam = trigger.params.mcbf;
        if (trigger.type == "mtbf") typeparam = trigger.params.mtbf;
        
        # get current triggers exposed property (TODO: attention: accessing "private" marked _path member, so this may break in the future...)
        var newtypeparam = getprop(trigger._path ~ "/" ~ trigger.type) or 0;
        
        # if property is different to internal state
        if (newtypeparam > 0 and (typeparam != newtypeparam or forceRearm)) {
            #print("Custom failure armed: " ~ failure.id);
            FailureMgr.get_trigger(failure.id).arm();
        } else if (newtypeparam == 0 and typeparam != newtypeparam) {
            #print("Custom failure disarmed: " ~ failure.id);
            FailureMgr.get_trigger(failure.id).disarm();
        } else {
            #print("Custom failure unchanged: " ~ failure.id);
        }

    }
}


# Simple actuator that disables an absolute property (set to 0)
var set_unserviceable_abs = func(path) {
    var prop = path;
    if (props.globals.getNode(prop) == nil) props.globals.initNode(prop, 1, "BOOL");
    return {
        parents: [FailureMgr.FailureActuator],
        set_failure_level: func(level) setprop(prop, level > 0 ? 0 : 1),
        get_failure_level: func { getprop(prop) ? 0 : 1 }
    }
}




############################################################################################
# Overall failure setup
# Define all custom failures here. they get picked up by the init and handling code below.
# Don't forget to enhance the gui too!
#
customFailures = [
    {id:"systems/fuel/aux-fuel-pump",    name:"Aux fuel pump",
        actuator: set_unserviceable_abs("/systems/fuel/fuel-pump-aux-serviceable"),
        trigger:  McbfTrigger.new("controls/engines/engine/fuel-pump", 0)
    },
    
    {id:"systems/fuel/engine-fuel-pump", name:"Engine fuel pump",
        actuator: set_unserviceable_abs("/systems/fuel/fuel-pump-engine-serviceable"),
        trigger:  McbfTrigger.new("engines/engine/running", 0)
    }
];




#----------------------------------------------------------------------------




#############################################################################################
# Initialize custom failures
#
foreach (failure; customFailures) {
    print("Custom failure init: " ~ failure.id);
    FailureMgr.add_failure_mode(failure.id, failure.name, failure.actuator);
    FailureMgr.set_trigger(failure.id, failure.trigger);
}

# TODO: Make this sensible to some user defined gui option
#       For now we just initialize a loop that checks if state changed, so we can pickup property param changes
# Another (more consistent with default failures) option would be to init a listener to each trigger to arm/disarm depending on property.
var updateCustomFailuresLoop = maketimer(1, updateAllExtendedFailures );
updateCustomFailuresLoop.start();


# TODO: Implement rearming of triggered but reset failures
#       This must probably also be called by the global repair function
# var ... = func() { enableAllExtendedFailures(); }

print("Custom failure modes init: done");
