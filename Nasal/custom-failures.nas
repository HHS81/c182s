#
# Extend FailureManager with aircraft specific failure options
#
# see: http://wiki.flightgear.org/A_Failure_Management_Framework_for_FlightGear
# see: https://sourceforge.net/p/flightgear/fgdata/ci/release/2017.3/%7E/tree/Nasal/FailureMgr/public.nas
# see: https://sourceforge.net/p/flightgear/fgdata/ci/release/2017.3/%7E/tree/Aircraft/Generic/Systems/failures.nas

io.include("Aircraft/Generic/Systems/failures.nas");  #include base compat failure modes (make default triggers (etc) available)


# Simple actuator that disables a property (set to 0)
var set_unserviceable_abs = func(path) {

    var prop = path;

    if (props.globals.getNode(prop) == nil)
        props.globals.initNode(prop, 1, "BOOL");

    return {
        parents: [FailureMgr.FailureActuator],
        set_failure_level: func(level) setprop(prop, level > 0 ? 0 : 1),
        get_failure_level: func { getprop(prop) ? 0 : 1 }
    }
}



#
# Set up the failure modes and their triggers
#
FailureMgr.add_failure_mode(
    "fuel/aux-fuel-pump",
    "Aux fuel pump",
    set_unserviceable_abs("/systems/fuel/fuel-pump-aux-serviceable")
);
FailureMgr.set_trigger("fuel/aux-fuel-pump", McbfTrigger.new("controls/engines/engine/fuel-pump", 200));
#FailureMgr.set_trigger("fuel/aux-fuel-pump", TimeoutTrigger.new(30));  # test purposes


FailureMgr.add_failure_mode(
    "fuel/engine-fuel-pump",
    "Engine fuel pump",
    set_unserviceable_abs("/systems/fuel/fuel-pump-engine-serviceable")
);
#FailureMgr.set_trigger("fuel/engine-fuel-pump", MtbfTrigger.new(20));
FailureMgr.set_trigger("fuel/engine-fuel-pump", McbfTrigger.new("engines/engine/running", 1000));



# Arm and enable all extended failures
customFailures = [{id:"fuel/aux-fuel-pump"}, {id:"fuel/engine-fuel-pump"}];
foreach (failure; customFailures) {
    print("enable custom failure: " ~ failure.id);
    FailureMgr.get_trigger(failure.id).arm();
    FailureMgr.get_trigger(failure.id).enable();
}


print("Extended failure modes initialized");
