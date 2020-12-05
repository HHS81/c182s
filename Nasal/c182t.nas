var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = getprop("/sim/aircraft-dir");
io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
#io.load_nasal(nasal_dir ~ 'Interfaces/GenericInterfaceController.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/c182t-InterfaceController.nas', "fg1000");  # use custom controller

var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance();
interfaceController.start();

# Create the FG1000
var fg1000system = fg1000.FG1000.getOrCreateInstance();

# Create a PFD as device 1, MFD as device 2
fg1000system.addPFD(1);
fg1000system.addMFD(2);

# Display the devices
fg1000system.display(1);
fg1000system.display(2);

#  Display a GUI version of device 1 at 50% scale.
#fg1000system.displayGUI(1, 0.5);

# Switch the FG1000 on/off depending on power.
setlistener("/systems/electrical/outputs/fg1000-pfd", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show(1);
      setprop("/instrumentation/FG1000/Lightmap", getprop("/controls/lighting/avionics-lights-norm"));
    } else {
      fg1000system.hide(1);
      setprop("/instrumentation/FG1000/Lightmap", 0.0);
    }
}, 0, 0);
setlistener("/systems/electrical/outputs/fg1000-mfd", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show(2);
      setprop("/instrumentation/FG1000/Lightmap", getprop("/controls/lighting/avionics-lights-norm"));
    } else {
      fg1000system.hide(2);
      setprop("/instrumentation/FG1000/Lightmap", 0.0);
    }
}, 0, 0);

# Control the backlighting of the bezel based on the avionics light knob
setlistener("/controls/lighting/avionics-lights-norm", func(n) {
    if (getprop("/systems/electrical/outputs/fg1000") > 5.0) {
      setprop("/instrumentation/FG1000/Lightmap", n.getValue());
    } else {
      setprop("/instrumentation/FG1000/Lightmap", 0.0);
    }
}, 0, 0);


#---------------------------------------------------------
# GMA1347 bridged to GMA340 implementation
# The GMA1347 currently just sets mixer controls which are mostly not wired to the actual needed properties in /instrumentation/...
# Some of the wired properties also get interfered with from the GMA340.
props.globals.getNode("controls/switches/mixer/com1", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/com[0]"));
props.globals.getNode("controls/switches/mixer/com1mic", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/com-mic[0]"));
props.globals.getNode("controls/switches/mixer/com2", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/com[1]"));
props.globals.getNode("controls/switches/mixer/com2mic", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/com-mic[1]"));
props.globals.getNode("controls/switches/mixer/com12", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/com1-2"));
props.globals.getNode("controls/switches/mixer/adf", 1).
    alias(props.globals.getNode("/instrumentation/adf[0]/ident-audible"));
props.globals.getNode("controls/switches/mixer/nav1", 1).
    alias(props.globals.getNode("/instrumentation/nav[0]/ident"));
props.globals.getNode("controls/switches/mixer/nav2", 1).
    alias(props.globals.getNode("/instrumentation/nav[1]/ident"));
props.globals.getNode("controls/switches/mixer/dme", 1).
    alias(props.globals.getNode("/instrumentation/dme[0]/ident"));
props.globals.getNode("controls/switches/mixer/hisens", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/hi"));
props.globals.getNode("controls/switches/mixer/mkrmute", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/mkr"));
props.globals.getNode("controls/switches/mixer/spkr", 1).
    alias(props.globals.getNode("/instrumentation/audio-panel/spkr"));


# Restore COM volumes with last known GMA340 setting
setprop("/instrumentation/comm[0]/volume", getprop("/instrumentation/comm[0]/volume-selected"));
setprop("/instrumentation/comm[1]/volume", getprop("/instrumentation/comm[1]/volume-selected"));

# store set COM value, but only if its > 0, so it gets properly restored on mute/unmute (ie. deselct of COM1 button)
setlistener("/instrumentation/comm[0]/volume", func(node) {
    if (node.getValue() > 0) setprop(node.getPath() ~ "-selected", node.getValue());
}, 1, 0);
setlistener("/instrumentation/comm[1]/volume", func(node) {
    if (node.getValue() > 0) setprop(node.getPath() ~ "-selected", node.getValue());
}, 1, 0);

# Enable exclusive use of COM1Mic or COM2Mic (manual p. 98)
setlistener("/instrumentation/audio-panel/com-mic[0]", func(node) {
    if (node.getValue()) {
        setprop("/instrumentation/audio-panel/com[0]", 1);
        setprop("/instrumentation/audio-panel/com[1]", 0);
        setprop("/instrumentation/audio-panel/com-mic[1]", 0);
    }
}, 1, 0);
setlistener("/instrumentation/audio-panel/com-mic[1]", func(node) {
    if (node.getValue()) {
        setprop("/instrumentation/audio-panel/com[1]", 1);
        setprop("/instrumentation/audio-panel/com[0]", 0);
        setprop("/instrumentation/audio-panel/com-mic[0]", 0);
    }
}, 1, 0);
