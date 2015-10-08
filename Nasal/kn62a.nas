# KN-62a DME Support
#
# Gary Neely aka 'Buckaroo'
#
# Released under GNU GENERAL PUBLIC LICENSE Version 2


# Round-off errors screw-up the textranslate animation used to display decimal place digits.
# This matters especially for frequencies where decimals must be accurate.
# I get around the problem by using a listener to split a freq into MHz and KHz components
# and copy these to a separate integer values used by the animations.
# An alternative solution to this issue is always welcome.

var dme_sel	= props.globals.getNode("/instrumentation/dme/frequencies/selected-mhz");
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
  if (mode == 0) {
    source = "nav[0]";
  }
  dme_src.setValue("/instrumentation/"~source~"/frequencies/selected-mhz");
});

