# KT-76c Transponder Support
#
# Gary Neely aka 'Buckaroo'
# Enhanced 2018 B. Hallinger (Multiplayer/ATCPie and more close to KT manual)
#
# Released under GNU GENERAL PUBLIC LICENSE Version 2


var kt76c_WARMUP	= 45;
var kt76c_COOLDN	= 300;

var kt76c_pwr		= props.globals.getNode("/systems/electrical/outputs/kt-76c");
var kt76c_fl		= props.globals.getNode("/instrumentation/transponder/flight-level");
var kt76c_code		= props.globals.getNode("/instrumentation/transponder/id-code");
var kt76c_id		= props.globals.getNode("/instrumentation/transponder/transmitted-id");
var kt76c_goodcode	= props.globals.getNode("/instrumentation/transponder/goodcode");
var kt76c_ready		= props.globals.getNode("/instrumentation/transponder/ready");
var kt76c_replying	= props.globals.getNode("/instrumentation/transponder/replying");
var kt76c_serviceable	= props.globals.getNode("/instrumentation/transponder/serviceable");
var kt76c_vfr_default	= props.globals.getNode("/instrumentation/transponder/factory-vfr-code", 1);
if (!kt76c_vfr_default.getValue()) kt76c_vfr_default.setIntValue(1200);  #set default factory VFR code unless already set

var kt76c_alt        = props.globals.getNode("/instrumentation/transponder/altitude");
var kt76c_alt_valid  = props.globals.getNode("/instrumentation/transponder/altitude-valid");
var kt76c_knob_state = props.globals.getNode("/controls/switches/kt-76c");
var kt76c_knob_mode  = props.globals.getNode("/instrumentation/transponder/inputs/knob-mode");
var kt76c_ident_btn  = props.globals.getNode("/instrumentation/transponder/inputs/ident-btn");
var kt76c_test       = props.globals.getNode("/instrumentation/transponder/testmode", 1);

var encoder_serviceable	= props.globals.getNode("/instrumentation/encoder/serviceable");

var kt76c_init      = 0;   # for internal init mode override
var kt76c_codes		= [];						# Array for 4 code digits
var kt76c_last		= [];						# Holds copy of last known good code


# Update transponders knob-mode for ATC clients
#   Translate: We must skip mode 3=GND; knob pos 3 must result in mode 4
#   Power and serviceable is also considered.
# Transmitted MP props are (multiplaymgr.cxx):
#   instrumentation/transponder/transmitted-id
#   instrumentation/transponder/altitude
#   instrumentation/transponder/ident
#   instrumentation/transponder/inputs/mode
#   instrumentation/transponder/ground-bit
#   instrumentation/transponder/airspeed-kt
var kt76c_updateMode = func() {
    var svc = kt76c_serviceable.getValue() or 0;
    var pwr = kt76c_pwr.getValue() or 0;
    var rdy = kt76c_ready.getValue() or 0;
    var im  = kt76c_knob_state.getValue();
    var om  = im;
    if  (im > 2)  om = om + 1;  # 2=2, but 3->4 and 4->5
    
    # announce test mode activation
    if  (im == 2) {
        kt76c_test.setIntValue(1);
    } else {
        kt76c_test.setIntValue(0);
    }
    
    # if power is lost, or not serviceable anymore, set mode to off
    if (!svc or pwr < 3) {
        om = 0;
        #print("KT76C transponder: update mode: im=" ~ im ~ "; om=" ~ om ~ "NOT SERVICEABLE / POWER LOST (svc=" ~ svc ~ "; PWR=" ~ pwr ~ ")");
    }
    
    # if not yet ready, do not tansmitt anything
    if (rdy < 0.95) {
        om = 0;
        #print("KT76C transponder: update mode: im=" ~ im ~ "; om=" ~ om ~ "NOT READY");
    }
    
    kt76c_knob_mode.setIntValue(om);
    #print("KT76C transponder: update mode: im=" ~ im ~ "; om=" ~ om);
}


# Update reply state
# The "R" sign blinks if operating or lights steadily in IDENT and TEST mode
kt76c_replyCycle   = 0;
var kt76c_updateReply = func() {
    var rs = 0; # reply state to finally set

    var im   = kt76c_knob_state.getValue();
    var svc  = kt76c_serviceable.getValue() or 0;
    var pwr  = kt76c_pwr.getValue() or 0;
    var rdy  = kt76c_ready.getValue() or 0;
    var tst  = kt76c_test.getValue() or 0;
    var idnt = getprop("/instrumentation/transponder/ident") or 0;

    # show reply sign when either IDENT is active, TEST mode selected or the blink cycle is at point 0.
    if (pwr and svc and rdy > 0.9 and im >= 2 and (tst or idnt or kt76c_replyCycle == 0)) {
        rs = 1;
    }
    
    #print("KT76C DBG: calc R-cycle=" ~ rs ~ "; im=" ~ im ~ "; svc=" ~ svc ~ "; pwr=" ~ pwr ~ "rdy=" ~ rdy ~ "; ident=" ~ idnt);
    kt76c_replying.setValue(rs);
}
var kt76c_updateReplyTimer = func() {
    # calculate reply state changes by cycle (this depends on the listener called per second)
    kt76c_replyCycle = kt76c_replyCycle + 1;
    if (kt76c_replyCycle > 4) kt76c_replyCycle = 0;
    
    kt76c_updateReply();
}
var kt76c_reply_update_timer = maketimer(1, kt76c_updateReplyTimer);
kt76c_reply_update_timer.simulatedTime = 1;
kt76c_reply_update_timer.singleShot = 0;



# Set next digit (push on list)
var kt76c_button_code = func(i) {					# i = 0-7
  if (!kt76c_pwr.getValue() and !kt76c_init) { return 0; }
  if (kt76c_test.getValue() and !kt76c_init) { return 0; }
  if (size(kt76c_codes) >= 4) { return 0; }				# Max of 4 digits
  append(kt76c_codes,i);
  if (size(kt76c_codes) == 4) {						# If we now have 4 digits, treat as a good
    kt76c_last = kt76c_codes;						# code and save; flag that we have a good
    kt76c_goodcode.setValue(1);						# code available to send
    kt76c_id.setValue(kt76c_codes);                 # set transmit good code via MP
  }
  else {
    kt76c_goodcode.setValue(0);
    kt76c_id.setValue(0000);
  }
  kt76c_copycode();
  #kt76c_entry_clock(0);
}


# Clear last digit (pop from list)
var kt76c_button_clr = func {
  if (!kt76c_pwr.getValue() and !kt76c_init) { return 0; }
  if (kt76c_test.getValue() and !kt76c_init) { return 0; }
  if (size(kt76c_codes)) {
    pop(kt76c_codes);
    kt76c_copycode();
  }
}


# Standard VFR code is 1200
var kt76c_button_vfr = func {
  if (!kt76c_pwr.getValue() and !kt76c_init) { return 0; }
  if (kt76c_test.getValue() and !kt76c_init) { return 0; }
  
  vfr = kt76c_vfr_default.getValue();
  vfr = vfr ~ ""; # convert to string so substr() can work
  vfr1 = substr(vfr, 0, 1);
  vfr2 = substr(vfr, 1, 1);
  vfr3 = substr(vfr, 2, 1);
  vfr4 = substr(vfr, 3, 1);

  for (var i=1; i<=4; i=i+1) kt76c_button_clr();
  foreach (c; [vfr1,vfr2,vfr3,vfr4]) kt76c_button_code(c);

  #kt76c_entry_clock(0);
}


# Send our good code for 18 seconds
var kt76c_button_idt = func {
  if (kt76c_pwr.getValue() < 3 and !kt76c_init) { return 0; }
  if (kt76c_test.getValue() and !kt76c_init) { return 0; }
  if (kt76c_goodcode.getValue() and kt76c_ready.getValue() == 1) {
    kt76c_ident_btn.setValue(1);
    kt76c_updateReply();
  }
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


# update encoded FL
# encoder prop mode-c-alt-ft must be polled (tied property, setlistener wont work)
var kt76c_updateFLcode = func {
  fl_strm = "---";  # default: display invalid
  var fl      = getprop("/instrumentation/encoder/mode-c-alt-ft") or 0;
  if (fl >= 0) {
    fl_strm    = fl ~ "";                  # convert to string so substr() can work
    fl_strm    = sprintf("%05d", fl_strm); # convert to 5 digits, prepended with zeros (7100 ft => 07100)
    fl_strm    = substr(fl_strm, 0, 3);    # convert to left 3 digits (07100 => 071)
  }
  
  # honor test mode
  var tst  = kt76c_test.getValue() or 0;
  if (tst) {
    fl_strm = "888";
  }
  
  kt76c_fl.setValue(fl_strm);
  #print("KT76C DBG:  fl=" ~ fl_strm ~ "; encoder=" ~ fl);
}
var kt76c_fl_update_timer = maketimer(2.5, kt76c_updateFLcode);
kt76c_fl_update_timer.simulatedTime = 1;
kt76c_fl_update_timer.singleShot = 0;


# Various things to do based on power switch settings
# TODO: This forces the listener on each power change. This is not good and uses more performance then neccessary.
setlistener(kt76c_pwr, func {
  if (kt76c_pwr.getValue() >= 3) {					# Enable transponder flight level encoder support
    #kt76c_serviceable.setValue("true");			# Note that power must also be on the encoder output
    kt76c_updateMode();
    encoder_serviceable.setValue("true");
  } else {
    #kt76c_serviceable.setValue("false");
    kt76c_updateMode();
    encoder_serviceable.setValue("false");
  }
  if (kt76c_pwr.getValue() > 0 and kt76c_ready.getValue() < 1)  {
    interpolate(kt76c_ready, 1, (1-kt76c_ready.getValue())*kt76c_WARMUP);
  }
  if (kt76c_pwr.getValue() == 0 and kt76c_ready.getValue() == 1) {
    interpolate (kt76c_ready, 0, kt76c_ready.getValue()*kt76c_COOLDN);
  }
  if (kt76c_pwr.getValue() < 3) {
    kt76c_replying.setValue(0);
    kt76c_alt_valid.setValue(0);
  } else {
    kt76c_alt_valid.setValue(1);
  }
  
  kt76c_updateReply();
}, 0 ,0);

# listen to serviceable property
setlistener(kt76c_serviceable, func {
    kt76c_updateMode();
});

# listen to knob changes
setlistener(kt76c_knob_state, func(n) {
    kt76c_updateMode();
    kt76c_updateFLcode();
    kt76c_updateReply();
});

# listen to test mode changes
var kt76c_test_codemem = [];
setlistener(kt76c_test, func(n) {
    if (n.getValue()) {
        # test mode entered
        kt76c_test_codemem = [];
        foreach (c; kt76c_last) append(kt76c_test_codemem, c);
        kt76c_code.setIntValue(8888);
    } else {
        # test mode leaved, reset previous code (and honor partial entries)
        for (var i=1; i<=4; i=i+1) kt76c_button_clr();
        foreach (c; kt76c_test_codemem) {
          kt76c_button_code(c);
        }
    }
}, 0, 0);

var kt76c_initialize = func() {
    # init goodcode with current saved code
    kt76c_init = 1;
    code = kt76c_code.getValue();
    if (code == nil or code == 0 or code == "") {
      print("KT76C transponder no saved code, setting VFR");
      kt76c_button_vfr();
    } else {
      print("KT76C transponder restore saved code ("~code~")");
      code = code ~ ""; # convert to string so substr() can work
      code1 = substr(code, 0, 1);
      code2 = substr(code, 1, 1);
      code3 = substr(code, 2, 1);
      code4 = substr(code, 3, 1);
    
      for (var i=1; i<=4; i=i+1) kt76c_button_clr();
      foreach (c; [code1,code2,code3,code4]) kt76c_button_code(c);
    }

    # init knob and instuments
    kt76c_updateMode();  #sync internal knob state to real knob state

    # init FL update
    kt76c_fl_update_timer.start();
    
    # init reply sign timer
    kt76c_reply_update_timer.start();

    kt76c_init = 0;
}

# INIT
setlistener("/sim/signals/fdm-initialized", func {
    kt76c_initialize();
    print("KT76C transponder initialized");
});
