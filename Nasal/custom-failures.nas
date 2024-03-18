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


# See if we have any saved state that should be restored later on.
# This also supports setting initial failures via commandline,
#   example: --prop:/sim/failure-manager/instrumentation/annunciator/failure-level=1
var failure_props   = props.globals.getNode("/sim/failure-manager/",1);
var failure_cats    = failure_props.getChildren();
var restoreFailures = [];
foreach (failCat; failure_cats) {
    var failure_cat_items  = failCat.getChildren();
    foreach (failCat_item; failure_cat_items) {
        # also search one level deeper
        var failure_cat_childs = failCat_item.getChildren();
        foreach (failCat_chld; failure_cat_childs) {
            append(failure_cat_items, failCat_chld);
        }
    }
    foreach (failCat_item; failure_cat_items) {
        var failure_level = failCat_item.getChild("failure-level");
        if (failure_level != nil and failure_level.getValue() > 0) {
            #print("DBG: failure-manager   " ~ failure_level.getPath() ~ "=" ~ failure_level.getValue());
            append(restoreFailures, [failure_level.getPath(), failure_level.getValue()]);  # prop=lvl
            failure_level.remove(); # unregister the node, so failur-maner initializes the triggers properly
        }
    }
}

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

# Actuator to disable random magnetos
# This selects between left, right and both magnetos by random chance
var fail_random_magnetos = func() {
    return {
        parents: [FailureMgr.FailureActuator],
        l_p:     "/controls/engines/engine/faults/left-magneto-serviceable",
        r_p:     "/controls/engines/engine/faults/right-magneto-serviceable",
        
        set_failure_level: func(level) {
            var l_svc = getprop(me.l_p);
            var r_svc = getprop(me.r_p);
        
            if (level > 0) {
                var leftFailed  = (rand() > 0.5)? 1 : 0;
                var rightFailed = (rand() > 0.5)? 1 : 0;
                if (!leftFailed and !rightFailed) {
                    # none failed -> fail both >:)
                   leftFailed  = 1;
                   rightFailed = 1;
                }
                if (leftFailed)  setprop(me.l_p, 0);
                if (rightFailed) setprop(me.r_p, 0);
                
            } else {
                setprop(me.l_p, 1);
                setprop(me.r_p, 1);
            }
            
        },
        get_failure_level: func {
            var l_svc = getprop(me.l_p);
            var r_svc = getprop(me.r_p);
            (l_svc == 0 or r_svc == 0)
        }
    }
}

# Simple actuator that disables the GFC700 Autopilot
var set_unserviceable_gfc700 = func(path) {
    var prop = path;
    if (props.globals.getNode(prop) == nil) props.globals.initNode(prop, 1, "BOOL");
    return {
        parents: [FailureMgr.FailureActuator],
        set_failure_level: func(level) {
            if (level > 0) {
                setprop("/autopilot/GFC700/FSM/AP-off/current-index", 0);
                fg1000.GenericInterfaceController.getOrCreateInstance().GFC700InterfaceInstance.stop();
            }
            if (level == 0) fg1000.GenericInterfaceController.getOrCreateInstance().GFC700InterfaceInstance.start();
        },
        get_failure_level: func { getprop(prop) ? 0 : 1 }
    }
}


# Simple handling of random breaker failure.
# It consists of a specialized generic actuator, that selects some random breaker and sets a special propert "failed" there;
# this property is meant to indicate an electrical failure in the protected circuit popped that breaker.
# A listener to the normal breaker property will catch pilot breaker-resets and evaluate the "failed"-property.
# If a failed breaker with faulty circuit is reset, there is a chance that the electircal system will fail.
#   TODO: Breaker failure should be modelled more realistically when the elec system supports this (overvoltage, shorts and bus failures, maybe fire?).

# Function to register a "failed" prop and a listener to the breakers property, so we can detect a reset
var pop_breaker_registerElecFailureMode = func(breaker) {
    #print("Custom failures: registering breaker '" ~ breaker ~ "': " ~ breaker ~ "-failed");
    setprop(breaker ~ "-failed", 0);
    setlistener(breaker, func(node) {
        var brkp = node.getPath();
        #print("Custom failures: braker '" ~ brkp ~ "' changed to '" ~ getprop(brkp) ~ "'");
        # When the breaker is pushed in, kill elec system by random chance:
        if (getprop(brkp) and getprop(brkp ~ "-failed")) {
            #print("Custom failures: braker '" ~ brkp ~ "' pushed in, but was protecting a faulty circuit!");
            var chance = rand();
            if (chance >= 0.15) {
                #print("Custom failures: braker '" ~ brkp ~ "' elec damage triggered!");
                setprop("/sim/failure-manager/systems/electrical/serviceable", 0);
            }
        }
    });
}

# for all breakers known, register the failure mode and property
var breakersVector = props.globals.getNode("/controls/circuit-breakers/").getChildren();
#print("Custom failures: register " ~ size(breakersVector) ~ " breakers");
foreach(brknode; breakersVector) {
    var brkprop = brknode.getPath();
    if (!getprop(brkprop ~ "-failed")) {
        # only register breakers without "failed" property
        pop_breaker_registerElecFailureMode(brkprop);
    }
}

# Simple actuator that pops some random breakers and marks them as failed
var pop_breakerActuator = func() {
    return {
        parents: [FailureMgr.FailureActuator],
        set_failure_level: func(level) {
            # use global variable above, otherwise we need to filter out the "-failed" ones  =>  var breakersVector = props.globals.getNode("/controls/circuit-breakers/").getChildren();
            if (level > 0) {
                var count_r = rand();
                var howmany = 0;
                if (count_r >= 0.8) howmany = 3;
                if (count_r >= 0.5) howmany = 2;
                if (count_r <  0.5) howmany = 1;
                #print("Custom failures: breaker actuator now popping " ~ howmany ~ " breakers");
                for (var i=1; i <= howmany; i=i+1) {
                    var which = math.floor(rand() * size(breakersVector)); #gives random index (0->size)
                    #print("Custom failures: breaker actuator pop i=" ~ which ~ " (" ~ breakersVector[which].getPath() ~ ")");
                    var brkprop = breakersVector[which].getPath();
                    setprop(brkprop, 0);
                    setprop(brkprop ~ "-failed", 1);
                }
                
            } else {
                foreach(brknode; breakersVector) {
                    var brkprop = brknode.getPath();
                    #print("Custom failures: breaker actuator reset/repair " ~ brkprop);
                    setprop(brkprop, 1);
                    setprop(brkprop ~ "-failed", 0);
                }
            }
        },
        get_failure_level: func {
            var r = 0;
            foreach(brknode; breakersVector) {
                var brkfprop = brknode.getPath() ~ "-failed";
                if (getprop(brkfprop) ==1) {
                    r = 1;
                }
            }
            #print("Custom failures: breaker actuator return failure level=" ~ r);
            (r > 0)
        }
    }
}



############################################################################################
# Overall failure setup
# Define all custom failures here. they get picked up by the init and handling code below.
# Don't forget to enhance the gui too!
#

# common systems to all C182 variants
customFailures_c182common = [

    {id:"instrumentation/fuelIndicator[0]",    name:"Left fuel indicator",
        actuator: set_unserviceable("/instruments/fuelIndicator[0]"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/fuelIndicator[1]",    name:"Right fuel indicator",
        actuator: set_unserviceable("/instruments/fuelIndicator[1]"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/egt",    name:"EGT",
        actuator: set_unserviceable("/instruments/egt"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/cht",    name:"CHT",
        actuator: set_unserviceable("/instruments/cht"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/oil-temp",    name:"OIL temp",
        actuator: set_unserviceable("/instruments/oil-temp"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/oil-press",    name:"OIL press",
        actuator: set_unserviceable("/instruments/oil-press"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/vac",    name:"VAC",
        actuator: set_unserviceable("/instruments/vac"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/amp",    name:"AMP",
        actuator: set_unserviceable("/instruments/amp"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/manfold-press",    name:"Manifold pres.",
        actuator: set_unserviceable("/instruments/manfold-press"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/fuel-flow",    name:"Fuel flow",
        actuator: set_unserviceable("/instruments/fuel-flow"),
        trigger:  MtbfTrigger.new(0),
    },
    
    
    
    {id:"lighting/taxi-light",    name:"Taxi light",
        actuator: set_unserviceable_abs("/systems/electrical/taxi-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"lighting/landing-light",    name:"Landing light",
        actuator: set_unserviceable_abs("/systems/electrical/landing-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"lighting/nav-light",    name:"Nav lights",
        actuator: set_unserviceable_abs("/systems/electrical/nav-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"lighting/strobe-light",    name:"Strobe lights",
        actuator: set_unserviceable_abs("/systems/electrical/strobe-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"lighting/instruments",    name:"instruments/radio light",
        actuator: set_unserviceable_abs("/systems/electrical/instrument-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"lighting/cabin",    name:"cabin/glareshield/pedestal light",
        actuator: set_unserviceable_abs("/systems/electrical/cabin-light-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    
    {id:"instrumentation/marker-beacon",    name:"Marker beacon",
        actuator: set_unserviceable("instrumentation/marker-beacon"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/audio-panel",    name:"Audio panel",
        actuator: set_unserviceable("instrumentation/audio-panel"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"instrumentation/avionics/dme",    name:"DME",
        actuator: set_unserviceable("instrumentation/dme"),
        trigger:  MtbfTrigger.new(0),
    },
    
    
    # ADF is already in standards module (there is currently no distinction between radio and gauge)
    #{id:"instrumentation/avionics/adf",    name:"ADF",
    #    actuator: set_unserviceable("instrumentation/adf"),
    #    trigger:  MtbfTrigger.new(0),
    #},
    
    
    {id:"instrumentation/avionics/transponder",    name:"Transponder",
        actuator: set_unserviceable("instrumentation/transponder"),
        trigger:  MtbfTrigger.new(0),
    },
    
    
    
    
    {id:"systems/fuel/aux-fuel-pump",    name:"Aux fuel pump",
        actuator: set_unserviceable_abs("/systems/fuel/fuel-pump-aux-serviceable"),
        trigger:  MtbfTrigger.new(0),
    },
    
    {id:"systems/fuel/engine-fuel-pump", name:"Engine fuel pump",
        actuator: set_unserviceable_abs("/systems/fuel/fuel-pump-engine-serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/oil/engine-oil-pump", name:"Engine oil pump",
        actuator: set_unserviceable_abs("/engines/engine[0]/oil-pump/serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/electrical/alternator", name:"Alternator",
        actuator: set_unserviceable_abs("/systems/electrical/alternator-serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/electrical/battery", name:"Battery",
        actuator: set_unserviceable_abs("/systems/electrical/battery-serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/electrical/breakers", name:"Breakers",
        actuator: pop_breakerActuator(),
        trigger:  MtbfTrigger.new(0)
    },
    
    
    {id:"engine/governor", name:"Prop Governor",
        actuator: set_unserviceable_abs("/engines/engine[0]/governor/serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"engine/starter", name:"Starter",
        actuator: set_unserviceable_abs("/engines/engine[0]/starter/serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"engine/magnetos", name:"Magnetos",
        actuator: fail_random_magnetos(),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/stall-horn", name:"Stall horn",
        actuator: set_unserviceable("/controls/stall-horn"),
        trigger:  MtbfTrigger.new(0)
    },
    
    {id:"systems/pitot-heat", name:"Pitot heat",
        actuator: set_unserviceable_abs("/systems/pitot/pitot-heat-serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
    
];

# Airplane variant specific failures
var customFailures_special = {
    c182s:[
        {id:"instrumentation/clock",    name:"Davtron 803 clock",
            actuator: set_unserviceable_abs("/instrumentation/clock/serviceable"),
            trigger:  MtbfTrigger.new(0),
        },
        {id:"instrumentation/annunciator",    name:"Annunciator panel",
            actuator: set_unserviceable("instrumentation/annunciator"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/autopilot",    name:"Autopilot",
            actuator: set_unserviceable("autopilot/kap140"),
            trigger:  MtbfTrigger.new(0),
        },
        {id:"instrumentation/avionics/autopilot-roll-servo",    name:"Autopilot (Roll servo)",
            actuator: set_unserviceable("autopilot/kap140/servo/roll-servo"),
            trigger:  MtbfTrigger.new(0),
        },
        {id:"instrumentation/avionics/autopilot-pitch-servo",    name:"Autopilot (Pitch servo)",
            actuator: set_unserviceable("autopilot/kap140/servo/pitch-servo"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/comm[0]",    name:"NAV1/COMM1",
            actuator: set_unserviceable("instrumentation/comm[0]"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/comm[1]",    name:"NAV2/COMM2",
            actuator: set_unserviceable("instrumentation/comm[1]"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"systems/electrical/avionics-fan[1]", name:"Avionics Fan",
        actuator: set_unserviceable_abs("/systems/electrical/avionics-fan[1]/serviceable"),
        trigger:  MtbfTrigger.new(0)
    },
        
    ],
    c182t:[
        {id:"systems/electrical/battery-stndby", name:"STBY Battery",
            actuator: set_unserviceable_abs("/systems/electrical/battery-sby-serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        
        {id:"systems/electrical/avionics-fan", name:"Avionics Fan 1",
            actuator: set_unserviceable_abs("/systems/electrical/avionics-fan/serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        
        {id:"systems/electrical/avionics-fan[1]", name:"Avionics Fan 2",
            actuator: set_unserviceable_abs("/systems/electrical/avionics-fan[1]/serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        
        # Clock failure is not implemented ion FG1000 yet
        {id:"instrumentation/clock",    name:"FG1000 clock",
            actuator: set_unserviceable_abs("/instrumentation/clock/serviceable"),
            trigger:  MtbfTrigger.new(0),
        },
        {id:"instrumentation/gps", name:"GPS receiver",
            actuator: set_unserviceable_abs("/instrumentation/gps/serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        
        {id:"instrumentation/fg1000/screen1", name:"FG1000 PFD",
            actuator: set_unserviceable_abs("instrumentation/fg1000/screen1/serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        {id:"instrumentation/fg1000/screen2", name:"FG1000 MFD",
            actuator: set_unserviceable_abs("instrumentation/fg1000/screen2/serviceable"),
            trigger:  MtbfTrigger.new(0)
        },
        
        {id:"autopilot/GFC700",    name:"GFC700 Autopilot",
            actuator: set_unserviceable_gfc700("autopilot/GFC700/serviceable"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/comm[0]",    name:"COMM1",
            actuator: set_unserviceable("instrumentation/comm[0]"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/comm[1]",    name:"COMM2",
            actuator: set_unserviceable("instrumentation/comm[1]"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/nav[0]",    name:"NAV1",
            actuator: set_unserviceable("instrumentation/nav[0]"),
            trigger:  MtbfTrigger.new(0),
        },
        
        {id:"instrumentation/avionics/nav[1]",    name:"NAV2",
            actuator: set_unserviceable("instrumentation/nav[1]"),
            trigger:  MtbfTrigger.new(0),
        },
    ]
};


#
# choose failure set according to aircraft type
#
customFailures = customFailures_c182common;
foreach (failureToAdd; customFailures_special[getprop("/sim/aircraft")]) {
    append(customFailures, failureToAdd);
}


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

# register a "serviceable" property in the failure manager item tree
# (this is mainly used by the GUI to immediately fail an item trough the actuator)
var registerSVCProp = func(failureID) {
    # register the serviceable property and listen for changes
    var svcPath = "/sim/failure-manager/" ~ failureID ~ "/serviceable";
    var failSVCprop = props.globals.initNode(svcPath, 1, "BOOL");
    setlistener(failSVCprop, func(node){
        if (node.getBoolValue()) {
            #print("Custom failure serviceable-prop changed to SVCBLE: " ~ failureID);
            FailureMgr.set_failure_level(failureID, 0);
        } else {
            #print("Custom failure serviceable-prop changed to FAILED: " ~ failureID);
            FailureMgr.set_failure_level(failureID, 1);
        }
    }, 0, 0);
    
    # register "backlink" on failure-level to update the internal svc property we just created.
    # This is mainly needed to let the failure be triggered again from the gui, but may be used otherwise too.
    # (TODO: this code interacts directly with failureManager internal properties and avoids the API. This is bad, but i don't know a better approach currently)
    var lvlPath = "/sim/failure-manager/" ~ failureID ~ "/failure-level";
    setlistener(lvlPath, func(node){
        var node_parent = node.getParent(); # the failure mode base tree
        var node_svc    = node_parent.getNode("serviceable");

        var newState = (node.getValue() > 0)? 0 : 1;
        node_svc.setBoolValue(newState);
        #print("DBG: RESET internal SVC " ~ node.getPath() ~ " to " ~ newState);
    }, 0, 0);
    
    # maybe via events?? This does nothing so far... :/
#    FailureMgr.events["trigger-fired"].subscribe( func(mode_id, trigger) {
#        var newState = (FailureMgr.get_failure_level(mode_id) > 0)? 0 : 1;
#        setProp(svcPath, newState);
#        print("DBG: RESET internal SVC " ~ svcPath ~ " to " ~ newState);
#    } );
}

# Init some random failures
# (called by GUI mode)
var initRandomFailures = func() {  
    var howmany = getprop("/sim/failure-manager/surprise-mode/amount") or 0;
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
        print("Custom failure randomFailureTimer: restarted with t=" ~ time);
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
    #print("Custom failure init: " ~ failure.id);
    FailureMgr.add_failure_mode(failure.id, failure.name, failure.actuator);
    FailureMgr.set_trigger(failure.id, failure.trigger);
    
    # Attach listener to trigger parameter, so trigger can be armed/disarmed/updated depending on property
    var trigger = FailureMgr.get_trigger(failure.id);
    var trigParamPath = trigger._path ~ "/" ~ trigger.type; #TODO: again attention: accessing "private" marked _path member, so this may break in
    if (substr(trigParamPath, 0, 1) != "/") trigParamPath = "/" ~ trigParamPath; # make path absolute so it can be matched against node.getPath() return
    path2Trigger[trigParamPath] = trigger;
    setlistener(trigParamPath, updateTriggerParameter, 0, 0);
    
    # register a serviceable-property in the failure prop tree that can trip the failure
    registerSVCProp(failure.id);
}

# Maybe we want to init saved failures at startup?
#   Then we need to:
#    - add the mbtf/mcbf-propertys to savestate
#    - change the trigger creation to pickout the saved value
#    - uncomment the line below
# updateAllExtendedFailures();


# Make default failure manager quiet if requested.
# (we need to use a custom property here, because failure-manager
#  seems to set 'display-on-screen' to '1' before we reach our code)
if (getprop("/sim/failure-manager/quiet")) {
    print("Custom failure modes: request quiet failure-manager on startup...");
    setprop("/sim/failure-manager/display-on-screen", 0);
}

print("Custom failure modes init: done");


# Init failure modes in case requested by startup.
# This can be done by providing the following properties through the laucher or cli:
#  + random failures (fail at most n systems in max x time)
#     --prop:/sim/failure-manager/surprise-mode/amount=<number>
#     --prop:/sim/failure-manager/surprise-mode/maxtime=<minutes> (optional, default 30)
#
#  + random surprise mode (fail one system every x minutes): 
#     --prop:/sim/failure-manager/surprise-mode/timer-active=1
#     --prop:/sim/failure-manager/surprise-mode/timer=<minutes>  (optional, default 30)
#
#  To also turn off screen messages, use:
#     --prop:/sim/failure-manager/quiet=1
#
setlistener("/sim/signals/fdm-initialized", func {
    if (getprop("/sim/failure-manager/surprise-mode/amount")) {
        print("Custom failure modes: request random failures on startup...");
        if (!getprop("/sim/failure-manager/surprise-mode/maxtime")) setprop("/sim/failure-manager/surprise-mode/maxtime", 30);
        initRandomFailures();
    }
    
    if (getprop("/sim/failure-manager/surprise-mode/timer-active")) {
        print("Custom failure modes: request surprise mode on startup...");
        if (!getprop("/sim/failure-manager/surprise-mode/timer")) setprop("/sim/failure-manager/surprise-mode/timer", 30);
        setprop("/sim/failure-manager/surprise-mode/timer-active",0);  # reset it, so timer will start
        initRandomFailureTimer();
    }
    
    # restore any saved failures, if user requested it
    if (getprop("/sim/failure-manager/restore-on-start")) {
        foreach (rf; restoreFailures) {
            print("failure-manager: restoring " ~ rf[0] ~ " to level " ~ rf[1]);
            setprop(rf[0], rf[1]);
        }
    }
    
    # register all present failure level properties for savestate
    var failure_props   = props.globals.getNode("/sim/failure-manager/",1);
    var failure_cats    = failure_props.getChildren();
    foreach (failCat; failure_cats) {
        var failure_cat_items = failCat.getChildren();
        foreach (failCat_item; failure_cat_items) {
            # also search one level deeper
            var failure_cat_childs = failCat_item.getChildren();
            foreach (failCat_chld; failure_cat_childs) {
                append(failure_cat_items, failCat_chld);
            }
        }
        foreach (failCat_item; failure_cat_items) {
            var failure_level = failCat_item.getChild("failure-level");
            if (failure_level != nil) {
                #print("DBG: failure-manager register propslist for save: " ~ failure_level.getPath());
                aircraft.data.add(failure_level.getPath());
            }
        }
    }

});
