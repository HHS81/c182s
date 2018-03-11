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

# Arm/Unarm trigger based on its state; that is: rearm if MCBF/MTBF >0 (or forceRearm is 1), otherwise disable
var updateExtendedFailureTriggerArming = func(trigger, forceRearm=0) {
    # get triggers current internal state
    var typeparam = nil;
    if (trigger.type == "mcbf") typeparam = trigger.params.mcbf;
    if (trigger.type == "mtbf") typeparam = trigger.params.mtbf;
    
    # get current triggers exposed property (TODO: attention: accessing "private" marked _path member, so this may break in the future...)
    var newtypeparam = getprop(trigger._path ~ "/" ~ trigger.type) or 0;
    
    # if property is different to internal state
    if (newtypeparam > 0 and (typeparam != newtypeparam or forceRearm)) {
        #print("trigger armed: " ~ trigger._path);
        trigger.arm();
    } else if (newtypeparam == 0 and typeparam != newtypeparam) {
        #print("trigger disarmed: " ~ trigger._path);
        trigger.disarm();
    } else {
        #print("trigger unchanged: " ~ trigger._path);
    }
}

# Update all extended failures arming status
var updateAllExtendedFailures = func(forceRearm=0) {
    foreach (failure; customFailures) {
        var trigger = FailureMgr.get_trigger(failure.id);
        updateExtendedFailureTriggerArming(trigger, forceRearm);
    }
}

# React to change of trigger parameter value 
# (Called by listeners attached to trigger params)
#   The problem we face here is that all we know in the callback is the path of the changed node, but we need the trigger object.
#   To circumvent, we make a dictionary that resolves paths to trigger objects and that is populated at init time.
#   Here we can lookup the dictionary efficiently and get the correct trigger object.
var path2Trigger = {};
var updateTriggerParameter = func(node) {
    #print("node changed: " ~ node.getPath() ~ "; " ~ node.getValue());
    updateExtendedFailureTriggerArming(path2Trigger[node.getPath()], 0);
} 



#############################################################################################
# Custom FailureMgr components
#

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
        #trigger:  McbfTrigger.new("controls/engines/engine/fuel-pump", 0)
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"systems/fuel/engine-fuel-pump", name:"Engine fuel pump",
        actuator: set_unserviceable_abs("/systems/fuel/fuel-pump-engine-serviceable"),
        #trigger:  McbfTrigger.new("engines/engine/running", 0)
        trigger:  MtbfTrigger.new(0)
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
    
    # Attach listener to trigger parameter, so trigger can be armed/disarmed/updated depending on property
    var trigger = FailureMgr.get_trigger(failure.id);
    var trigParamPath = trigger._path ~ "/" ~ trigger.type; #TODO: again attention: accessing "private" marked _path member, so this may break in
    if (substr(trigParamPath, 0, 1) != "/") trigParamPath = "/" ~ trigParamPath; # make path absolute so it can be matched against node.getPath() return
    path2Trigger[trigParamPath] = trigger;
    setlistener(trigParamPath, updateTriggerParameter, 0, 0);
}

# Maybe we want to init failures at startup?
#   Then we need to:
#    - add the mbtf/mcbf-propertys to savestate
#    - change the trigger creation to pickou the saved value
#    - uncomment the line below
# updateAllExtendedFailures();

print("Custom failure modes init: done");
