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

var audioPanel_powerVolts  = props.globals.getNode("/systems/electrical/outputs/audio-panel", 1)
  .alias("/systems/electrical/outputs/fg1000-pfd");

# Switch the FG1000 on/off depending on power.
setlistener("/systems/electrical/outputs/fg1000-pfd", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show(1);
    } else {
      fg1000system.hide(1);
    }
}, 0, 0);
setlistener("/systems/electrical/outputs/fg1000-mfd", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show(2);
    } else {
      fg1000system.hide(2);
    }
}, 0, 0);