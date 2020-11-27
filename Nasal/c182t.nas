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
setlistener("/systems/electrical/outputs/fg1000", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show();
      setprop("/instrumentation/FG1000/Lightmap", getprop("/controls/lighting/avionics-lights-norm"));
    } else {
      fg1000system.hide();
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
