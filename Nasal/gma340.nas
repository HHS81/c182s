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
var gma340_com_mic0       = props.globals.getNode("/instrumentation/audio-panel/com-mic[0]");
var gma340_com_mic1       = props.globals.getNode("/instrumentation/audio-panel/com-mic[1]");
var gma340_com_mic2       = props.globals.getNode("/instrumentation/audio-panel/com-mic[2]");
var gma340_serviceable    = props.globals.getNode("/instrumentation/audio-panel/serviceable");
var gma340_powerbtn       = props.globals.getNode("/instrumentation/audio-panel/power-btn");
var gma340_operable       = props.globals.getNode("/instrumentation/audio-panel/operable",1);
var gma340_powerVolts     = props.globals.getNode("/systems/electrical/outputs/audio-panel");
var gma340_spkrbtn        = props.globals.getNode("/instrumentation/audio-panel/spkr");

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

# get FGCom state
var fgcom_spkr_volume    = props.globals.getNode("/sim/fgcom/speaker-level");
var fgcom_radio_selected = props.globals.getNode("/controls/radios/comm-radio-selected", 1);
var fgcom_radio_ptt = [
        props.globals.getNode("/instrumentation/comm[0]/ptt", 1),
        props.globals.getNode("/instrumentation/comm[1]/ptt", 1),
        props.globals.getNode("/instrumentation/comm[2]/ptt", 1)   #note: no com3 installed, but can be selected in GMA; so this way we avoid an outofBounds error at line 223 (ptt-release) below.
    ];

# Make a looped timer so we can let the MIC led blink when FGCom PTT is pressed
var gma340_blinker   = props.globals.getNode("/instrumentation/audio-panel/ptt_blinker", 1);
var gma340_blinker_c = 4;
var gma340_blinkloop = maketimer(0.2, func(){
        if (gma340_blinker_c == 0) {
            gma340_blinker_c = 4;
            gma340_blinker.setValue(0);
        } else {
            gma340_blinker_c = gma340_blinker_c - 1;
            gma340_blinker.setValue(1);
        }
});
gma340_blinkloop.simulatedTime = 1;
        

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

# Calculate FGCom speaker volume
# called from spkr button after press
var gma340_spkr_oldVolume = -1;
var gma340_refresh_spkr_volume = func {
    # The FGCom speaker-volume is controlled from the FGCom dialog (in real-life it's set factory-side).
    # Current behavior is that if GMA340 power is lost (or turned off), the speaker
    # setting remains the same. I guessed that from the intended behaviour, because
    # if GMA340 fails, internal wiring for mic and audio falls back to COM1.
    # Note, the speaker is only ever used from FGCom when the radios volumes are down,
    # otherwise the selected COM volume is used.
    var spkr_vol  = fgcom_spkr_volume.getValue();
    var spkrbtn   = gma340_spkrbtn.getValue();
    
    # init for the first time - record current manual user setting for later restore
    if (gma340_spkr_oldVolume == -1) {
        #print("GMA340: initialize cabin speaker: ", spkr_vol);
        gma340_spkr_oldVolume = spkr_vol;
    }
    
    if (spkrbtn) {
        # Button ON: reset old setting
        #print("GMA340: SPKR set to ON, restore volume: ", spkr_vol, "->", gma340_spkr_oldVolume);
        fgcom_spkr_volume.setValue(gma340_spkr_oldVolume);
        
    } else {
        # Button OFF: remember current setting, then set to zero
        #print("GMA340: SPKR set to OFF, mute volume: ", spkr_vol, "-> 0");
        gma340_spkr_oldVolume = spkr_vol;
        fgcom_spkr_volume.setValue(0);
    }
};

# PTT function, gets called when pressing/releasing space
#   active: 1 if ptt is pressed
#   mode: 0 normal, 1 shift-space
var gma340_ptt = func(active, mode) {
    var modifiers = props.globals.getNode("/devices/status/keyboard");
    var fgcom_integration = getprop("/instrumentation/audio-panel/fgcom-integration");
    if (fgcom_integration == nil) fgcom_integration = 0;
    #print("GMA340: PTT integrated=", fgcom_integration, "; active=", active, "; mode=", mode, "; modifiers=",  modifiers.getValue());
    
    if (fgcom_integration) {
        # FGCom integration activated: detect which radio is activated at the panel and if it is operable
        var selectedRadio = gma340_get_selected_radio();
        if (active) {
            #print("GMA340: [PTT] activated; panel selected radio COM", selectedRadio + 1);
            var selectedRadio_isOK = gma340_check_radio(selectedRadio);
            if (selectedRadio_isOK) {
                print("GMA340: [PTT] now transmitting on selected radio COM", selectedRadio + 1);
                fgcom_radio_ptt[selectedRadio].setValue(1);
            } else {
                # Radio was not operable
                print("GMA340: [PTT] selected radio COM", selectedRadio + 1, " is not operable. Not sending transmission!");
            }
            
        } else {
            print("GMA340: [PTT] released, selected radio=COM", selectedRadio + 1);
            fgcom_radio_ptt[selectedRadio].setValue(0);  # possible outOfBounds error, see comment at fgcom_radio_ptt definition above
        }
    
    } else {
        # FGCom not integrated: tunnel trough to standard behavior
        # we use the listeners the default implementation listens to.
        
        # space pressed
        if (active and mode == 0) {
            fgcom_radio_ptt[0].setValue(1);
            
        # space released
        } else if (!active and mode == 0) {
            fgcom_radio_ptt[0].setValue(0);
            
        # shift-space pressed
        } else if (active and mode == 1) {
            fgcom_radio_ptt[1].setValue(1);
            
        # shift-space released
        } else if (!active and mode == 1) {
            fgcom_radio_ptt[1].setValue(0);
            
        # fallback
        } else {
            fgcom_radio_ptt[0].setValue(0);
            fgcom_radio_ptt[0].setValue(0);
        }
    }
    
};

# Updater function for FGComs internal selectd-radio property
# This checks if the currently selected radio is operable and adjusts
# the property accordingly.
var gma340_fgcom_updateServiceable = func() {
    var fgcom_integration = getprop("/instrumentation/audio-panel/fgcom-integration");
    if (fgcom_integration == nil) fgcom_integration = 0;
    if (fgcom_integration) {
        var selectedRadio = gma340_get_selected_radio();
        var selectedRadio_isOK = gma340_check_radio(selectedRadio);
       # print("GMA340: FGCom integration active; checking radio status of COM", selectedRadio +1);
        
        if (! selectedRadio_isOK) {
            #print("GMA340:     COM", selectedRadio + 1, " failed: disabling");
            fgcom_radio_selected.setValue(0); #0=disconnected
            # ... as soon as the PTT is pressed or some voltage changes etc,
            # the property is reestablished automatically.
            
        } else {
            fgcom_radio_selected.setValue(selectedRadio + 1 );
        }
    }
};

# Get prinicipially selected radio from GMA panel
# This just returns the selected switch (or failsafe selection).
# On GMA340 failure, hardwired failsafe revert to COM1.
# SPLIT-COM feature of GMA340 not Implemented: Pressing the COM 1/2 button
#    activates the Split COM function. There Pilot and Copilot can transmit on
#    separate radios, but FGCom is singleplayer...
# returns: 0=COM1, 1=COM2, 2=COM3
var gma340_get_selected_radio = func() {
    var pwrSw     = gma340_powerbtn.getValue();
    var svcabl    = gma340_serviceable.getValue();
    var volts     = getprop("/systems/electrical/outputs/audio-panel");
    
    if (pwrSw and svcabl and volts > 20) {
        # GMA Panel is operable: get selected switch
        var ret = 0;
        if (gma340_com_mic0.getValue() == 1) ret = 0;
        if (gma340_com_mic1.getValue() == 1) ret = 1;
        if (gma340_com_mic2.getValue() == 1) ret = 2;
        #print("GMA340: panel operable, selected_radio=COM", ret + 1);
        return ret;
    } else {
        # Audio panel ist not operable: fial-safe hardwired to COM1
        #print("GMA340: panel not operable, failsafe=COM1");
        return 0;
    }
};

# Check if an com device is operable
# param selectedRadio is property index (com1=0, ...)
var gma340_check_radio = func(selectedRadio) {
    var radioStatus = 1;  # return value
    
    # check if the selected radio is operational
    selCom_pwr   = getprop("/instrumentation/comm[" ~ selectedRadio ~ "]/power-btn");
    selCom_volts = getprop("systems/electrical/outputs/comm[" ~ selectedRadio ~ "]");
    selCom_svabl = getprop("/instrumentation/comm[" ~ selectedRadio ~ "]/serviceable");
    #print("GMA340: [PTT] Check radio COM", selectedRadio + 1, ": pwr=",selCom_pwr,"; volts=",selCom_volts,"; svabl=",selCom_svabl );
    
    if (selCom_pwr and selCom_volts > 22 and selCom_svabl) {
        #print("GMA340: [PTT] radio COM", selectedRadio + 1, ": is up and running.");
        radioStatus = 1;
        
    } else {
        #print("GMA340: [PTT] radio COM", selectedRadio + 1, ": is NOT operable.");
        radioStatus = 0;
    }
    
    return radioStatus;

};


var refresh_com_volumes = func {
    refresh_com0_volume();
    refresh_com1_volume();
    refresh_marker_volume();
    refresh_ident_volume();
    gma340_fgcom_updateServiceable();
    gma340_fgcom_updateOperable();
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


# Calculate standard operable property
var gma340_fgcom_updateOperable = func() {
    var pwrSw  = gma340_powerbtn.getValue();
    var svcabl = gma340_serviceable.getValue();
    var volts  = getprop("/systems/electrical/outputs/audio-panel");

    if (pwrSw and svcabl and volts) {
        gma340_operable.setBoolValue(1);
    } else {
        gma340_operable.setBoolValue(0);
    }
};

# Initialize GMA 340 at startup (delayed, so propertys are properly initialized)
setlistener("/sim/signals/fdm-initialized", func {
    var delayInit = 1; # delay in seconds
    
    var gma340_init = maketimer(delayInit, func(){

        # Monitor changes to GMA-340 switches
        setlistener("/instrumentation/audio-panel/com[0]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/com[1]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/com-mic[0]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/com-mic[1]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/com-mic[2]", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/power-btn", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/serviceable", refresh_com_volumes, 1, 0);
        setlistener("/instrumentation/audio-panel/spkr", refresh_com_volumes, 1, 0);
        
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
        
        # Monitor changes to general FGCom integration
        setlistener("/instrumentation/audio-panel/fgcom-integration", refresh_com_volumes, 1, 0);

        # init the first time
        refresh_com_volumes();
        gma340_refresh_spkr_volume();

        
        print("GMA340 audio panel initialized");
    });
    gma340_init.singleShot = 1;
    gma340_init.start();
    gma340_blinkloop.start();
});
