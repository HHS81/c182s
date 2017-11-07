#
# GMA 340 audio panel
# small helperscript to handle muting/unmuting the comms
# as there seems to be no dedicated property to toggle and power-btn is already occupied.
#
# The idea is to monitor selections on the audio panel and then set the volume accordingly.
# The volume setting is read from the COMM instrument.
#
# (c) 2017 Benedikt Hallinger, public domain
#

# get GMA-340 switch states
var gma340_com0           = props.globals.getNode("/instrumentation/audio-panel/com[0]");
var gma340_com1           = props.globals.getNode("/instrumentation/audio-panel/com[1]");
var gma340_serviceable    = props.globals.getNode("/instrumentation/audio-panel/serviceable");
var gma340_powerbtn       = props.globals.getNode("/instrumentation/audio-panel/power-btn");
var gma340_powerVolts     = props.globals.getNode("/systems/electrical/outputs/audio-panel");

# get preset values. This is assumed to be set from the volume-knob.
var comm0_volume_selected = props.globals.getNode("instrumentation/comm[0]/volume-selected");
var comm1_volume_selected = props.globals.getNode("instrumentation/comm[1]/volume-selected");

# get handles to comm devices
var comm0 = props.globals.getNode("instrumentation/comm[0]");
var comm1 = props.globals.getNode("instrumentation/comm[1]");

# get COM power states
var comm0_pwrSwitch   = comm0.getNode("power-btn");
var comm0_serviceable = comm0.getNode("serviceable");
var comm1_pwrSwitch   = comm1.getNode("power-btn");

# get COM real volume used by the simulator to play audio
var comm0_volume = comm0.getNode("volume");
var comm1_volume = comm1.getNode("volume");



# Functions to calculate correct state of internal volume of comms
var refresh_com0_volume = func {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");

    #print("com0 change: pwrSw='", pwrSw, "'; svcabl='", svcabl, "';  volts='", volts, "'");
    if (pwrSw and svcabl and volts) {
        # Normal operation
        if (gma340_com0.getValue() and comm0_pwrSwitch.getValue()) {
            #print("unmute com0:", comm0_volume_selected.getValue());
            comm0_volume.setDoubleValue(comm0_volume_selected.getValue());
        } else {
            comm0_volume.setDoubleValue(0);
            #print("muted com0");
        }
        
    } else {
        # Fail-State-Mode: when failure/power-off: connect pilot headset/mic directly to COM1
        var com0_volts  = getprop("/systems/electrical/outputs/comm");
        if (comm0_pwrSwitch.getValue() and comm0_serviceable.getValue() and com0_volts) {
            # wire directly to com0; for that com0 must be operable
            #print("unmute com0 (fail-safe):", comm0_volume_selected.getValue());
            comm0_volume.setDoubleValue(comm0_volume_selected.getValue());
        } else {
            #print("muted com0 (fail-safe failed)");
            comm0_volume.setDoubleValue(0);
        }
    }
};
var refresh_com1_volume = func {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");

    if (pwrSw and svcabl and volts) {
        # Normal operation
        if (gma340_com1.getValue() and comm1_pwrSwitch.getValue()) {
            #print("unmute com1:", comm1_volume_selected.getValue());
            comm1_volume.setDoubleValue(comm1_volume_selected.getValue());
        } else {
            comm1_volume.setDoubleValue(0);
            #print("muted com1");
        }
        
    } else {
        # power-loss: no volume
        comm1_volume.setDoubleValue(0);
        #print("muted com1 (power loss)");
    }
};
var refresh_com_volumes = func {
    refresh_com0_volume();
    refresh_com1_volume();
};



# Initialize GMA 340 at startup (delayed, so propertys are properly initialized)
setlistener("/sim/signals/fdm-initialized", func {
    var delayInit = 1; # delay in seconds
    
    var gma340_init = maketimer(delayInit, func(){
        # Monitor changes to GMA-340 switches
        setlistener("/instrumentation/audio-panel/com[0]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/com[1]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/power-btn", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/serviceable", refresh_com_volumes, 1, 0);
        
        # Monitor changes to voltage
        setlistener("/systems/electrical/outputs/audio-panel", refresh_com_volumes, 1, 0);

        # Monitor changes to volume selection knob of comms
        setlistener("/instrumentation/comm[0]/volume-selected", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/comm[1]/volume-selected", refresh_com_volumes, 1, 0);
        
        # Monitor also state changes to the power unit switch of the COMMs
        setlistener("/instrumentation/comm[0]/power-btn", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/comm[1]/power-btn", refresh_com_volumes, 1, 0);
        
        # Monitor electrical systems
        setlistener("/systems/electrical/serviceable", refresh_com_volumes, 1, 0);

        # init the first time
        refresh_com_volumes();

        
        print("GMA340 audio panel initialized");
    });
    gma340_init.singleShot = 1;
    gma340_init.start();
});
