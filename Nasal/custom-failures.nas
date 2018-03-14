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
    {id:"instrumentation/clock",    name:"Davtron 803 clock",
        actuator: set_unserviceable_abs("/instrumentation/clock/serviceable"),
        trigger:  MtbfTrigger.new(0),
    },

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

# register a random timer failure
# (needed to avoid the loop variable problem)
var registerRandomFailureTimer = func(t_fire, failure){
    var timer = maketimer(t_fire, failure, func(){
        print("Custom failure initRandomFailures: execute " ~ me.description ~ "(" ~ me.id ~ ")");
        FailureMgr.set_failure_level(me.id, 1);
    });
    timer.singleShot = 1;
    timer.simulatedTime = 1;
    #timer.start();
    
    return timer;
}

# Init some random failures
# (called by GUI mode)
var initRandomFailures = func() {  
    var howmany = getprop("/sim/failure-manager/surprise-mode/ammount") or 0;
    var maxtime = getprop("/sim/failure-manager/surprise-mode/maxtime") or 0;
    var maxseconds = maxtime * 60;
    print("Custom failure initRandomFailures: " ~ howmany ~ " in " ~ maxtime ~ " minutes (" ~ maxseconds ~ "s)");
    
    #choose the random failures
    var allKnownFailures = FailureMgr.get_failure_modes();  # returns vector with hashes: { id, description }
    #print("DBG: i know " ~ size(allKnownFailures) ~ " failure modes...");
    for (var i=1; i <= howmany; i=i+1) {
        var which = math.floor(rand() * size(allKnownFailures)); #gives index to failuremodes (0->size)
        var t_fire = math.round(rand() * maxseconds);
        print("Custom failure initRandomFailures: picked " ~ i ~ ": " ~ which ~ "; t=" ~ t_fire ~ "; failure=" ~ allKnownFailures[which].description ~ " (" ~ allKnownFailures[which].id ~ ")");
        var timer = registerRandomFailureTimer(t_fire, allKnownFailures[which]);
        timer.start();
        
    }
}

# Init some random failures each time period
# (called by GUI mode)
var randomFailureTimer = maketimer(99999999, func(){
    #choose the random failures
    var allKnownFailures = FailureMgr.get_failure_modes();  # returns vector with hashes: { id, description }
    var which = math.floor(rand() * size(allKnownFailures)); #gives index to failuremodes (0->size)
    var theFailure = allKnownFailures[which];
    print("Custom failure randomFailureTimer: execute " ~ theFailure.description ~ "(" ~ theFailure.id ~ ")");
    FailureMgr.set_failure_level(theFailure.id, 1);
});
randomFailureTimer.simulatedTime = 1;
var initRandomFailureTimer = func() {
    var running = getprop("/sim/failure-manager/surprise-mode/timer-active") or 0;
    var time    = getprop("/sim/failure-manager/surprise-mode/timer") * 60;
    
    if (!running) {
        # start the timer
        print("Custom failure randomFailureTimer: restarted with t= " ~ time);
        randomFailureTimer.restart(time);
    } else {
        print("Custom failure randomFailureTimer: stopped"); 
        randomFailureTimer.stop();
    }
    setprop("/sim/failure-manager/surprise-mode/timer-active", !running);
}


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
