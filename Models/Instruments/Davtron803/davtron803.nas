###############################################################################
##
## Davtron 803
##
##  Original from Nasal for DR400-dauphin by dany93;
##                    Clément de l'Hamaide - PAF Team - http://equipe-flightgear.forumactif.com
##  Canvas/Proprules implementation 2021 by Benedikt Hallinger
##
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################



################
# Some utils
################

# Floor function
var floor = func(v) v < 0.0 ? -int(-v) - 1 : int(v);

# Time format function: Format time of property from secs to HH:MM format
var timeFormat = func(timeValue, type, flash=1){
  if (timeValue > 359940) timeValue = 359940;  # clamp to 99:59 HH:MM
  hrs = floor(timeValue/3600);
  min = floor(timeValue/60);
  sec = timeValue;

  if (type == "ft" or timeValue > 3599) {
    # Display HH:MM after 59:59 minute/ timer or always with flight timer
    formattedTime = sprintf("%02d:%02d", hrs, min-(60*hrs));
  } else {
    # Display MM:SS
    formattedTime = sprintf("%02d:%02d", min, sec-(60*min));
  }
  
  # if we are in adjust mode, let the selected digit flash
  if (flash) {
    var adjust_digit = getprop("/instrumentation/davtron803/internal/bot-mode-set") or 0;
    if (adjust_digit > 0 and adjust_digit < 5) {
        #print("Davtron 803: timeFormat("~timeValue~", "~type~") flash digit "~adjust_digit);
        var flasher = getprop("/instrumentation/davtron803/annunciators/flasher");
        if (!flasher) {
            #print("Davtron 803: timeFormat("~timeValue~", "~type~") flash formattedTime="~formattedTime);
            if (adjust_digit >= 3) adjust_digit = adjust_digit + 1;  # to accomodate for the colon: "12:34"
            var formattedTime_v = split("", formattedTime);
            #print("Davtron 803: timeFormat("~timeValue~", "~type~") flash formattedTime_v="~string.join("|",formattedTime_v));
            formattedTime_v[adjust_digit-1] = "    ";
            formattedTime = string.join("",formattedTime_v);
        }
    }
  }
  
  #print("Davtron 803: timeFormat("~timeValue~", "~type~") returns: '"~formattedTime~"'");
  return formattedTime;
}



############################
# Canvas setup
############################
#print("Davtron 803 init: canvas");
var davtron_lcd_test_top    = "88.8E";
var davtron_lcd_test_bottom = "88:88";
var my_canvas = canvas.new({
  "name": "Davtron803",   # The name is optional but allow for easier identification
  "size": [1024, 1024], # Size of the underlying texture (should be a power of 2, required) [Resolution]
  "view": [1024, 1024],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
                        # which will be stretched the size of the texture, required)
  "mipmapping": 1       # Enable mipmapping (optional)
});

# add the canvas to replace basic texture of models lcd element
my_canvas.addPlacement({"node": "lcd"});
#my_canvas.setColorBackground(0, 1, 0, .5);

# create groups holding some stuff
var bggroup  = my_canvas.createGroup();
var lcdgroup = my_canvas.createGroup();

# load davtron png image as background
bggroup.createChild("image")
        .setFile("Models/Instruments/Davtron803/Davtron803.png")
        .setSize(1024,1024)
        .setTranslation(-3, 0);      

# Create text element for upper line
var lcdfont = "DSEG/DSEG7/Classic/DSEG7Classic-Bold.ttf";
#var lcdfont = "DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf";
var lcd_line_top = lcdgroup.createChild("text", "davtron.top.lcd.text_canvas")
                .setTranslation(250, 340)    # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont(lcdfont)            # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_ROOT/Fonts
                .setFontSize(160, 1.0)       # Set fontsize and optionally character aspect ratio
                .setColor(0,0,0)             # Text color
                .setText(davtron_lcd_test_top);

# draw the horizontal divider bar
var lcd_divider = lcdgroup.createChild("path", "davtron.top.lcd.divider_canvas")
        .setStrokeLineWidth(8).set("stroke", "rgba(0,0,0,1)")
        .moveTo(110, 447)
        .horizTo(900);

# Create text element for lower line
var lcd_line_bot = lcdgroup.createChild("text", "davtron.bot.lcd.text_canvas")
                .setTranslation(365, 565)    # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont(lcdfont)            # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_ROOT/Fonts
                .setFontSize(160, 1.0)       # Set fontsize and optionally character aspect ratio
                .setColor(0,0,0)             # Text color
                .setText(davtron_lcd_test_bottom);

# Create text elements for mode selection
var lcd_modes1 = lcdgroup.createChild("text", "davtron.bot.lcd.modes1_canvas")
                .setTranslation(130, 500)    # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont("LiberationFonts/LiberationSans-Bold.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_ROOT/Fonts
                .setFontSize(80, 1.0)       # Set fontsize and optionally character aspect ratio
                .setColor(0,0,0)             # Text color
                .setText("UT LT");
var lcd_modes2 = lcdgroup.createChild("text", "davtron.bot.lcd.modes2_canvas")
                .setTranslation(130, 600)    # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont("LiberationFonts/LiberationSans-Bold.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_ROOT/Fonts
                .setFontSize(80, 1.0)       # Set fontsize and optionally character aspect ratio
                .setColor(0,0,0)             # Text color
                .setText("FT ET")
                .setScale(1, 1.02);

# Underlining of selected item
# TODO: Should be little arrows instead of just lines...
var lcd_modesel = [
    lcdgroup.createChild("path", "davtron.bot.lcd.modesel_ut_canvas")
        .setStrokeLineWidth(8).set("stroke", "rgba(0,0,0,1)")
        .moveTo(130, 545)
        .horizTo(235),
    lcdgroup.createChild("path", "davtron.bot.lcd.modesel_lt_canvas")
        .setStrokeLineWidth(8).set("stroke", "rgba(0,0,0,1)")
        .moveTo(260, 545)
        .horizTo(355),
    lcdgroup.createChild("path", "davtron.bot.lcd.modesel_ft_canvas")
        .setStrokeLineWidth(8).set("stroke", "rgba(0,0,0,1)")
        .moveTo(130, 645)
        .horizTo(230),
    lcdgroup.createChild("path", "davtron.bot.lcd.modesel_et_canvas")
        .setStrokeLineWidth(8).set("stroke", "rgba(0,0,0,1)")
        .moveTo(255, 645)
        .horizTo(355)
];
lcd_modesel[0].srcProp = props.globals.getNode("/instrumentation/davtron803/annunciators/ut");
lcd_modesel[1].srcProp = props.globals.getNode("/instrumentation/davtron803/annunciators/lt");
lcd_modesel[2].srcProp = props.globals.getNode("/instrumentation/davtron803/annunciators/ft");
lcd_modesel[3].srcProp = props.globals.getNode("/instrumentation/davtron803/annunciators/et");



###########################
# Canvas driving code
###########################


# Update power state
var davtron_updatePowerState = func() {
    var pwr = getprop("/instrumentation/davtron803/operable");
    if (pwr) {
        davtron_update();

        lcd_line_top.show();
        lcd_divider.show();
        lcd_line_bot.show();
        lcd_modes1.show();
        lcd_modes2.show();
    } else {
        lcd_line_top.hide();
        lcd_divider.hide();
        lcd_line_bot.hide();
        lcd_modes1.hide();
        lcd_modes2.hide();
    }

    #print("Davtron 803: davtron_updatePowerState() with "~pwr);
}

# Update the state of the selected top mode
var davtron_updateTopMode = func(){
    var value = davtron_lcd_test_top;
    var mode = getprop("/instrumentation/davtron803/internal/top-mode") or 0;
    if        (mode == 0) {
        value = sprintf("%5.1fE", getprop("/systems/electrical/volts") or 0);
    } else if (mode == 1) {
        value = sprintf("%7.0fF", getprop("/environment/temperature-degf") or 0);
    } else if (mode == 2) {
        value = sprintf("%7.0fC", getprop("/environment/temperature-degc") or 0);
    } else {
        # should not happen. Check XML config
    }
    if (getprop("/instrumentation/davtron803/logic/test")) value = davtron_lcd_test_top;
    
    lcd_line_top.setText(value);
    #print("Davtron 803: davtron_updateTopMode() with mode="~mode~", result="~value);
};

# Update the state of the selected bottom mode
var davtron_updateBottomMode = func(){
    var value = davtron_lcd_test_bottom;
    var mode    = getprop("/instrumentation/davtron803/internal/bot-mode") or 0;
    var modeset = getprop("/instrumentation/davtron803/internal/bot-mode-set") or 0;
    if (mode == 0) {  #UT
        value = getprop("/instrumentation/clock/indicated-short-string") or 0;
        
    } else if (mode == 1) { #LT
        value = getprop("/instrumentation/clock/local-short-string") or 0;
        
    } else if (mode == 2) { #FT
        if (modeset == 0) {
            value = timeFormat(getprop("/instrumentation/davtron803/flight-time-secs") or 0, "ft");
        } else {
            value = timeFormat(getprop("/instrumentation/davtron803/internal/flight-timer-alarm-time") or 0, "ft");
        }
        
    } else if (mode == 3) { #ET
        value = timeFormat(getprop("/instrumentation/davtron803/elapsed-time-secs") or 0, "et");
        
    } else {
        # should not happen. Check XML config
    }
    if (getprop("/instrumentation/davtron803/logic/test")) value = davtron_lcd_test_bottom;
    
    if (getprop("/instrumentation/davtron803/annunciators/alarm")) {
        var flasher = getprop("/instrumentation/davtron803/annunciators/flasher");
        if (!flasher) value = "";
    }
    
    lcd_line_bot.setText(value);
    
    #print("Davtron 803: davtron_updateBottomMode() with mode="~mode~", result="~value);
};

# Update the state of the mode annunciators
var davtron_updateModeAnnunciators = func(i){
    if (i >= 0) {
        if (lcd_modesel[i].srcProp.getBoolValue()) {
            lcd_modesel[i].show();
        } else {
            lcd_modesel[i].hide();
        }
    } else {
        for (i=0; i<=3; i = i+1) {
            davtron_updateModeAnnunciators(i);
        }
    }

    #print("Davtron 803: davtron_updateModeAnnunciators("~i~") complete");
};


# Recalculate all displays
var davtron_update = func() {
    davtron_updateTopMode();
    davtron_updateBottomMode();
    davtron_updateModeAnnunciators(-1); # recalc all of them
    #print("Davtron 803: davtron_update()");
};



####################
# Timers / counters
####################

var davtron_shared_timer = func(tp, tsp) {
    var ts = getprop(tsp) or 0;
    var tv = getprop(tp) or 0;

    if (tv == 999999) return; # do nothing on "magic reset value"
    
    var tgt = tv + ts;
    if (tgt > 359940) tgt = 359940;  # do not wrap around but stop at 99:59 HH:MM
    if (tgt < 0) tgt = 0;  # do not go negative
    setprop(tp, tgt);
};

var davtron_ft_timer = maketimer(1, func(){
    davtron_shared_timer("/instrumentation/davtron803/flight-time-secs", "/instrumentation/davtron803/internal/flight-timer-step");
});
davtron_ft_timer.simulatedTime = 1;

var davtron_et_timer = maketimer(1, func(){
    davtron_shared_timer("/instrumentation/davtron803/elapsed-time-secs", "/instrumentation/davtron803/internal/elapsed-timer-step");
});
davtron_et_timer.simulatedTime = 1;

# Listen to changes in timer's step size
setlistener("/instrumentation/davtron803/internal/flight-timer-step", func(p){
    if (p.getValue() != 0) {
        davtron_ft_timer.start();
    } else {
        davtron_ft_timer.stop();
    }
}, 0, 0);
setlistener("/instrumentation/davtron803/internal/elapsed-timer-step", func(p){
    if (p.getValue() != 0) {
        davtron_et_timer.start();
    } else {
        davtron_et_timer.stop();
    }
}, 0, 0);



######################
# Model knob hooks
######################

# Called when in adjust mode the control button was pressed to change the digit
var adjustDigit = func() {
    var curDigit = getprop("/instrumentation/davtron803/internal/bot-mode-set");
    var mode     = getprop("/instrumentation/davtron803/internal/bot-mode");
    print("Davtron 803: adjustDigit() mode="~mode~"; curDigit="~curDigit);
    
    # mapping table for digit position to propname+seconds-factor for the given mode
    var modemap = [{},{},   # indexes 0,1 unused
        { #FT
            name:    "ft",
            prop:    "/instrumentation/davtron803/internal/flight-timer-alarm-time",
            factors: [nil, 36000, 3600, 600, 60] #FT: HH:MM, first idx unused
        },
        { #ET
            name:    "et",
            prop:    "/instrumentation/davtron803/elapsed-time-secs",
            factors: [nil,  600,  60, 10,  1]   #ET: MM:SS, first idx unused
        },
    ];
    
    # get current data
    var oldValue  = getprop(modemap[mode].prop);
    var time_fmt  = timeFormat(oldValue, modemap[mode].name, 0);
    var position  = curDigit;
    if (position >= 3) position = position + 1;  # to accomodate for the colon: "12:34"
    var digit_val = substr(time_fmt, position-1, 1);
    print("Davtron 803: adjustDigit() digit_val="~digit_val~" from: '"~time_fmt~"'");
    
    # calculate new value in seconds
    var newValue = oldValue - digit_val * modemap[mode].factors[curDigit];
    digit_val = digit_val + 1;
    if (digit_val == 10) digit_val = 0;  # wrap around
    newValue     = newValue + digit_val * modemap[mode].factors[curDigit];
    setprop(modemap[mode].prop, newValue);
};



###########
# Init
###########

setlistener("/sim/signals/fdm-initialized", func {

    #print("Davtron 803 init: update timers");
    # Update the TOP mode regularly
    davtron_loop_top = maketimer(2, davtron_updateTopMode);
    davtron_loop_top.simulatedTime = 0;
    davtron_loop_top.start();


    #print("Davtron 803 init: listeners");
    # Listen to changes in power and serviceable to enable/disable the clock
    setlistener("/instrumentation/davtron803/operable", davtron_updatePowerState, 1, 0);

    # Listen to changes in config so display responds timely
    setlistener("/instrumentation/davtron803/logic/test", davtron_update, 1, 0);
    setlistener("/instrumentation/davtron803/internal/top-mode", davtron_updateTopMode, 1, 0);
    setlistener("/instrumentation/davtron803/internal/bot-mode", davtron_updateBottomMode, 1, 0);
    setlistener("/instrumentation/davtron803/annunciators/ut", func(){davtron_updateModeAnnunciators(0);}, 1, 0);
    setlistener("/instrumentation/davtron803/annunciators/lt", func(){davtron_updateModeAnnunciators(1);}, 1, 0);
    setlistener("/instrumentation/davtron803/annunciators/ft", func(){davtron_updateModeAnnunciators(2);}, 1, 0);
    setlistener("/instrumentation/davtron803/annunciators/et", func(){davtron_updateModeAnnunciators(3);}, 1, 0);
    
    # Listen to timer changes
    setlistener("/instrumentation/davtron803/flight-time-secs", davtron_updateBottomMode, 1, 0);
    setlistener("/instrumentation/davtron803/elapsed-time-secs", davtron_updateBottomMode, 1, 0);

    # Listen to flasher and refresh bottom lcd in set mode
    setlistener("/instrumentation/davtron803/annunciators/flasher", func(){
        var adjust_digit = getprop("/instrumentation/davtron803/internal/bot-mode-set") or 0;
        var alarm_active = getprop("/instrumentation/davtron803/annunciators/alarm") or 0;
        if (alarm_active or adjust_digit > 0) davtron_updateBottomMode();
    }, 1, 0);
    
    print("Davtron 803 initialized");
});
