# KT-76c Transponder Support
#
# Gary Neely aka 'Buckaroo'
#
# Released under GNU GENERAL PUBLIC LICENSE Version 2


var kt76c_WARMUP	= 45;
var kt76c_COOLDN	= 300;

var kt76c_pwr		= props.globals.getNode("/systems/electrical/outputs/kt-76c");
var kt76c_fl		= props.globals.getNode("/instrumentation/transponder/flight-level");
var kt76c_code		= props.globals.getNode("/instrumentation/transponder/id-code");
var kt76c_goodcode	= props.globals.getNode("/instrumentation/transponder/goodcode");
var kt76c_ready		= props.globals.getNode("/instrumentation/transponder/ready");
var kt76c_replying	= props.globals.getNode("/instrumentation/transponder/replying");
var kt76c_serviceable	= props.globals.getNode("/instrumentation/transponder/serviceable");

var encoder_serviceable	= props.globals.getNode("/instrumentation/encoder/serviceable");

var kt76c_codes		= [];						# Array for 4 code digits
var kt76c_last		= [];						# Holds copy of last known good code


									# Set next digit (push on list)
var kt76c_button_code = func(i) {					# i = 0-7
  if (!kt76c_pwr.getValue()) { return 0; }
  if (size(kt76c_codes) >= 4) { return 0; }				# Max of 4 digits
  append(kt76c_codes,i);
  if (size(kt76c_codes) == 4) {						# If we now have 4 digits, treat as a good
    kt76c_last = kt76c_codes;						# code and save; flag that we have a good
    kt76c_goodcode.setValue(1);						# code available to send
  }
  else {
    kt76c_goodcode.setValue(0);
  }
  kt76c_copycode();
  #kt76c_entry_clock(0);
}

									# Clear last digit (pop from list)
var kt76c_button_clr = func {
  if (!kt76c_pwr.getValue()) { return 0; }
  if (size(kt76c_codes)) {
    pop(kt76c_codes);
    kt76c_copycode();
  }
}

									# Standard VFR code is 1200
var kt76c_button_vfr = func {
  if (!kt76c_pwr.getValue()) { return 0; }
  kt76c_codes = [1,2,0,0];
  kt76c_goodcode.setValue(1);
  kt76c_copycode();
  #kt76c_entry_clock(0);
}

									# Send our good code for 18 seconds
var kt76c_button_idt = func {
  if (kt76c_pwr.getValue() < 3) { return 0; }
  if (kt76c_goodcode.getValue() and kt76c_ready.getValue() == 1) {
    kt76c_replying.setValue(1);
    settimer(kt76c_disable_reply, 18);
  }
}


var kt76c_disable_reply = func {
  kt76c_replying.setValue(0);
}

									# Codes are held in an array; copycode forms an
									# integer from the code
var kt76c_copycode = func {
  if (!size(kt76c_codes)) {
    kt76c_code.setValue(0);
    return 0;
  }
  var codestr = "";
  for(var i=0; i < size(kt76c_codes); i+=1) {
    codestr = codestr ~ kt76c_codes[i];
  }
  var code = 0;
  code = code + codestr;
  kt76c_code.setValue(code);
}

									# Various things to do based on power switch settings
setlistener(kt76c_pwr, func {
  #if (kt76c_pwr.getValue() >= 3) {
  #  #enable blink prop
  #{
  #else {
  #  #disable link prop
  #}
  if (kt76c_pwr.getValue() > 0) {					# Enable transponder flight level encoder support
    kt76c_serviceable.setValue("true");					# Note that power must also be on the encoder output
    encoder_serviceable.setValue("true");
  }
  else {
    kt76c_serviceable.setValue("false");
    encoder_serviceable.setValue("false");
  }
  #if (kt76c_pwr.getValue() > 0 and kt76c_ready.getValue() < 1) }
  #  interpolate(kt76c_ready, 1, (1-kt76c_ready.getValue())*kt76c_WARMUP);
  #}
  #if (kt76c_pwr.getValue() == 0 and kt76c_ready.getValue() == 1) {
  #  interpolate (kt76c_ready, 0, kt76c_ready.getValue()*kt76c_COOLDN);
  #}
  #if (kt76c_pwr.getValue() < 3) {
  #  kt76c_replying.setValue(0);
  #  #setprop alt = 0
  #}
  #if (kt76c_pwr.getValue() == 4) {
  #  #setprop alt = 1
  #}
});
