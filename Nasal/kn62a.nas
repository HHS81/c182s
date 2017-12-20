
# KN-62a DME Support
#
# Gary Neely aka 'Buckaroo'
#
# Released under GNU GENERAL PUBLIC LICENSE Version 2

# storage for "previous dialed in frequency" since selected-mhz will get overwritten with NAV value
props.globals.initNode("/instrumentation/dme/frequencies/selected-mhz-prev", 108, "DOUBLE");

# Round-off errors screw-up the textranslate animation used to display decimal place digits.
# This matters especially for frequencies where decimals must be accurate.
# I get around the problem by using a listener to split a freq into MHz and KHz components
# and copy these to a separate integer values used by the animations.
# An alternative solution to this issue is always welcome.

var dme_sel	= props.globals.getNode("/instrumentation/dme/frequencies/selected-mhz");
var dme_selint	= props.globals.getNode("/instrumentation/dme/frequencies/selected-mhz-prev");
var dme_selmhz	= props.globals.getNode("/instrumentation/dme/frequencies/display-sel-mhz");
var dme_selkhz	= props.globals.getNode("/instrumentation/dme/frequencies/display-sel-khz");


# Update MHz and KHz sub-strings on freq changes
setlistener(dme_sel, func {
  var dmestr = sprintf("%.2f",dme_sel.getValue());	# String conversion
  var dmetemp = split(".",dmestr);			# Get sub-strings
  dme_selmhz.setValue(dmetemp[0]);
  dme_selkhz.setValue(dmetemp[1]);
});



var dme_mode	= props.globals.getNode("/controls/switches/kn-62a-mode");
var dme_src	= props.globals.getNode("/instrumentation/dme/frequencies/source");

# On mode changes, change frequency source:
#   mode 0 (RMT):  NAV1
#   mode 1 (Freq): DME internal
#   mode 2 (GS/T): DME internal
setlistener(dme_mode, func {
  var mode = dme_mode.getValue();
  var source = "dme";
  if (mode == 1) {
        dme_sel.setValue(dme_selint.getValue());
  }
  if (mode == 0) {
    # adjust source, overwriting selected-mhz
    source = "nav[0]";
  }
  dme_src.setValue("/instrumentation/"~source~"/frequencies/selected-mhz");
});


# Copy internal value to selected-mhz when mode==FREQ
setlistener(dme_selint, func {
    if (dme_mode.getValue() == 1) {
        dme_sel.setValue(dme_selint.getValue());
    }
});


# NAV-Mode: update selected freq in case NAV1 signal gets lost
var nav1_state = props.globals.getNode("/instrumentation/nav[0]/data-is-valid");
setlistener(nav1_state, func {

    if (dme_mode.getValue() == 0) {
        #var nav1_serviceable = getprop("/instrumentation/nav[0]/serviceable");
        #var nav1_energyOK    = getprop("/systems/electrical/outputs/nav[0]");
        #var nav1_powerOn     = getprop("/instrumentation/nav[0]/power-btn");
        #if ( nav1_serviceable and nav1_energyOK > 0 and nav1_powerOn ) {
        #    source = "nav[0]";
        #} else {
        #    # no value, when NAV1 not available
        #    source = "nav-not-available";
        #}
        if (nav1_state.getValue()) {
            dme_src.setValue("/instrumentation/nav[0]/frequencies/selected-mhz");
        } else {
            dme_src.setValue("nav1-not-available");
            setprop("/instrumentation/dme/in-range", 0);
        }
    }
});

# Switch off ident volume when power button is off
# (failing DME and loss-of-voltage is handled otherwise)
var dme_pwrBtn = props.globals.getNode("/controls/switches/kn-62a");
var updateIdentVolume = func {
    setprop("/instrumentation/dme/volume", dme_pwrBtn.getValue());
    setprop("/instrumentation/dme/power-btn", dme_pwrBtn.getValue()); #also adjust standard-property
};

setlistener(dme_pwrBtn, updateIdentVolume);
