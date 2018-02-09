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

# get preset marker beacon value. This is hard-wired factroy side but can be changed later.
var default_marker_volume = props.globals.getNode("instrumentation/marker-beacon/volume-default", 1);
if (!default_marker_volume.getValue()) default_marker_volume.setValue(0.5);

# get handles to comm devices
var comm0 = props.globals.getNode("instrumentation/comm[0]");
var comm1 = props.globals.getNode("instrumentation/comm[1]");

# get handles to NAV, DME and ADF devices
var nav0 = props.globals.getNode("instrumentation/nav[0]");
var nav1 = props.globals.getNode("instrumentation/nav[1]");
var dme  = props.globals.getNode("instrumentation/dme");
var adf  = props.globals.getNode("instrumentation/adf");

# get COM power states
var comm0_pwrSwitch   = comm0.getNode("power-btn");
var comm0_serviceable = comm0.getNode("serviceable");
var comm1_pwrSwitch   = comm1.getNode("power-btn");
var comm1_serviceable = comm1.getNode("serviceable");

# get COM real volume used by the simulator to play audio
var comm0_volume  = comm0.getNode("volume");
var comm1_volume  = comm1.getNode("volume");
var marker_volume = props.globals.getNode("instrumentation/marker-beacon/volume");



# Functions to calculate correct state of internal volume of comms
var refresh_com0_volume = func {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");
    var com0_volts  = getprop("/systems/electrical/outputs/comm[0]");

    #print("com0 change: pwrSw='", pwrSw, "'; svcabl='", svcabl, "';  volts='", volts, "'");
    if (pwrSw and svcabl and volts) {
        # Normal operation
        if (gma340_com0.getValue() and comm0_pwrSwitch.getValue() and comm0_pwrSwitch.getValue() and comm0_serviceable.getValue() and com0_volts) {
            #print("unmute com0:", comm0_volume_selected.getValue());
            comm0_volume.setDoubleValue(comm0_volume_selected.getValue());
        } else {
            comm0_volume.setDoubleValue(0);
            #print("muted com0");
        }
        
    } else {
        # Fail-State-Mode: when failure/power-off: connect pilot headset/mic directly to COM1
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
    var com1_volts  = getprop("/systems/electrical/outputs/comm[1]");

    if (pwrSw and svcabl and volts) {
        # Normal operation
        if (gma340_com1.getValue() and comm1_pwrSwitch.getValue() and comm1_pwrSwitch.getValue() and comm1_serviceable.getValue() and com1_volts) {
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
var refresh_marker_volume = func {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");

    if (pwrSw and svcabl and volts) {
        # normal operable: set default volume
        marker_volume.setDoubleValue(default_marker_volume.getValue());
        
    } else {
        # power-loss: no volume
        marker_volume.setDoubleValue(0);
    }
};
var refresh_ident_volume = func {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");

    if (pwrSw and svcabl and volts) {
        # normal operable: set default volume
        # TODO: Not implemented currently; should be done like the marker-volume probably.
        #       When power is lost, we just shut off the values, otherwise leave setting as-is.
        #       This has the drawback that we shut-off the ident when we switch off the GMA or electrical supply.
        
    } else {
        # power-loss: no volume
        var nav0_ident = nav0.getNode("ident");
        var nav1_ident = nav1.getNode("ident");
        var dme_ident  = dme.getNode("ident");
        var adf_ident  = adf.getNode("ident-audible");
        nav0_ident.setDoubleValue(0);
        nav1_ident.setDoubleValue(0);
        dme_ident.setDoubleValue(0);
        adf_ident.setDoubleValue(0);
    }
};

var refresh_com_volumes = func {
    refresh_com0_volume();
    refresh_com1_volume();
    refresh_marker_volume();
    refresh_ident_volume();
};


# Calulate marker-audio state
# called from marker button after press
var gma340_toggleMarkerMute = func() {
    var marker_state = props.globals.getNode("/instrumentation/marker-beacon/audio-btn");
    var gma_marker   = props.globals.getNode("/instrumentation/audio-panel/mkr");
    
    if (gma_marker.getBoolValue()) {
        # when button was set to ON, set audio-out to on
        marker_state.setBoolValue(1);
        gma_marker.setBoolValue(1);
        
    } else {
        # when button was set to OFF:
        #  - if marker-beacon not active, just disable
        #  - if marker-beacon is active, disable too, but reactivate
        #  - if marker is actually muted, unmute instantly
        
        # unmute in case it was muted temporarily before
        if (!marker_state.getBoolValue() and !gma_marker.getBoolValue()) {
            gma_marker.setBoolValue(1);
            marker_state.setBoolValue(1);
            return;
        }
        
        # mute and disable mkr-button on panel
        marker_state.setBoolValue(0);
        gma_marker.setBoolValue(0);
        
        # Detect marcer-beacon activity
        # now sample the marker-beacon properties for changes.
        # This can't be done easily with listeners, because they are tied properties.
        # We poll as long as one of the markers is true and after then remain silent again, reactivate the audio.
        var beacon_active    = 0;
        var tp               = "/sim/time/elapsed-sec";
        var last_seen_change = getprop(tp);
        var marker_inner     = props.globals.getNode("/instrumentation/marker-beacon/inner");
        var marker_middle    = props.globals.getNode("/instrumentation/marker-beacon/middle");
        var marker_outer     = props.globals.getNode("/instrumentation/marker-beacon/outer");
        var poll_loop = maketimer(0.1, func(){
            var now = getprop(tp);
            if (marker_inner.getBoolValue() or marker_middle.getBoolValue() or marker_outer.getBoolValue()) {
                # marker is active: update timestamp and other stuff
                beacon_active    = 1;
                last_seen_change = now;
                gma_marker.setBoolValue(1); # activate panel display, so user sees its only temporary muted
            }
            
            # see if tha last change is too long ago, if yes abort loop
            if (last_seen_change < now - 2) {
                poll_loop.stop();  # end loop
                if (beacon_active) {
                    # if beacon was active, we turn on the audio now, as the mute should only be temporary
                    marker_state.setBoolValue(1);
                }
            }
         
        });
        poll_loop.start();
    }
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
        setlistener("/systems/electrical/outputs/comm[0]", refresh_com_volumes, 1, 0);
        setlistener("/systems/electrical/outputs/comm[1]", refresh_com_volumes, 1, 0);

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
