
# liveries =========================================================
aircraft.livery.init("Aircraft/c182s/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");

#following ground equipement stuff placing was only possible by the help of the work by: Melchior Franz, Anders Gidenstam, Detelf Faber, onox. Thanks!
#wheel chocks======================================================



var chocks001_model = {
       index:   0,
       add:   func {
                          #print("chocks001_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;

		var chocks001 = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/chock001.ac", chocks001,
				props.globals.getNode("/orientation/heading-deg").getValue());
					 me.index = i;
          },

       remove:   func {
                #print("chocks001_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/chocks001/enable", func(n) {
		if (n.getValue()) {
				chocks001_model.add();
		} else  {
			chocks001_model.remove();
		}
	});
}
settimer(init_common,0);

##

var chocks002_model = {
       index:   0,
       add:   func {
                          #print("chocks002_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;

		var chocks002 = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/chock002.ac", chocks002,
				props.globals.getNode("/orientation/heading-deg").getValue());
					 me.index = i;
          },

       remove:   func {
                #print("chocks002_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/chocks002/enable", func(n) {
		if (n.getValue()) {
				chocks002_model.add();
		} else  {
			chocks002_model.remove();
		}
	});
}
settimer(init_common,0);

##

var chocks003_model = {
       index:   0,
       add:   func {
                          #print("chocks003_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;

		var chocks003 = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/chock003.ac", chocks003,
				props.globals.getNode("/orientation/heading-deg").getValue());
					 me.index = i;
          },

       remove:   func {
                #print("chocks003_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/chocks003/enable", func(n) {
		if (n.getValue()) {
				chocks003_model.add();
		} else  {
			chocks003_model.remove();
		}
	});
}
settimer(init_common,0);


#safety-cones======================================================


var coneR_model = {
       index:   0,
       add:   func {
                          #print("coneR_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var cones = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/safety-cone_R.ac", cones,
				props.globals.getNode("/orientation/heading-deg").getValue());
				 me.index = i;
          },

       remove:   func {
                #print("coneR_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/coneR/enable", func(n) {
		if (n.getValue()) {
				coneR_model.add();
		} else  {
			coneR_model.remove();
		}
	});
}
settimer(init_common,0);

##

var coneL_model = {
       index:   0,
       add:   func {
                          #print("coneL_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var cones = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/safety-cone_L.ac", cones,
				props.globals.getNode("/orientation/heading-deg").getValue());
				 me.index = i;
          },

       remove:   func {
                #print("coneL_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/coneL/enable", func(n) {
		if (n.getValue()) {
				coneL_model.add();
		} else  {
			coneL_model.remove();
		}
	});
}
settimer(init_common,0);



#ground-power======================================================


var gpu_model = {
       index:   0,
       add:   func {
                          #print("gpu_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;

		var gpu = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/external-power.xml", gpu,
				props.globals.getNode("/orientation/heading-deg").getValue());
		 me.index = i;
          },

       remove:   func {
                #print("gpu_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/gpu/enable", func(n) {
		if (n.getValue()) {
				gpu_model.add();
		} else  {
			gpu_model.remove();
		}
	});
}
settimer(init_common,0);




#ladder======================================================


var ladder_model = {
       index:   0,
       add:   func {
                          #print("ladder_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var ladder = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/ladder.xml", ladder,
				props.globals.getNode("/orientation/heading-deg").getValue());

		 me.index = i;

          },

       remove:   func {
                #print("ladder_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/ladder/enable", func(n) {
		if (n.getValue()) {
				ladder_model.add();
		} else  {
			ladder_model.remove();
		}
	});
}
settimer(init_common,0);


#fueltanktrailer======================================================


var fueltanktrailer_model = {
       index:   0,
       add:   func {
                          #print("fueltanktrailer_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var fueltanktrailer = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/fueltanktrailer.xml", fueltanktrailer,
				props.globals.getNode("/orientation/heading-deg").getValue());

		 me.index = i;

          },

       remove:   func {
                #print("fueltanktrailer_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/fueltanktrailer/enable", func(n) {
		if (n.getValue()) {
				fueltanktrailer_model.add();
		} else  {
			fueltanktrailer_model.remove();
		}
	});
}
settimer(init_common,0);


#Engine PreHeater======================================================


var EngPreHeat_model = {
       index:   0,
       add:   func {
                          #print("EngPreHeat_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var EngPreHeat = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());

		geo.put_model("Aircraft/c182s/Models/Exterior/RedDragonEnginePreHeater.ac", EngPreHeat,
				props.globals.getNode("/orientation/heading-deg").getValue());

		 me.index = i;

          },

       remove:   func {
                #print("EngPreHeat_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/engines/engine/external-heat/enabled", func(n) {
		if (n.getValue()) {
				EngPreHeat_model.add();
		} else  {
			EngPreHeat_model.remove();
		}
	});
}
settimer(init_common,0);


# doors ============================================================
DoorL       = aircraft.door.new( "/sim/model/door-positions/DoorL", 2, 0 );
DoorR       = aircraft.door.new( "/sim/model/door-positions/DoorR", 2, 0 );
BaggageDoor = aircraft.door.new( "/sim/model/door-positions/BaggageDoor", 2, 0 );
WindowR     = aircraft.door.new( "/sim/model/door-positions/WindowR", 2, 0 );
WindowL     = aircraft.door.new( "/sim/model/door-positions/WindowL", 2, 0 );

# restore saved door state
DoorL_saved       = getprop("/sim/model/door-positions/DoorL/position-norm") or 0;
DoorR_saved       = getprop("/sim/model/door-positions/DoorR/position-norm") or 0;
BaggageDoor_saved = getprop("/sim/model/door-positions/BaggageDoor/position-norm") or 0;
WindowL_saved     = getprop("/sim/model/door-positions/WindowL/position-norm") or 0;
WindowR_saved     = getprop("/sim/model/door-positions/WindowR/position-norm") or 0;
DoorL.setpos(DoorL_saved);
DoorR.setpos(DoorR_saved);
BaggageDoor.setpos(BaggageDoor_saved);
WindowL.setpos(WindowL_saved);
WindowR.setpos(WindowR_saved);


#####################
# Adjust properties when in motion
# - external electrical disconnect when groundspeed higher than 0.1ktn (replace later with distance less than 0.01...)
# - remove external heat
ad = func {
    GROUNDSPEED = getprop("/velocities/groundspeed-kt") or 0;
    AGL         = getprop("/position/altitude-agl-ft")  or 0;

    if (GROUNDSPEED > 0.1) {
        setprop("/controls/electric/external-power", "false");
        #setprop("/engines/engine/external-heat/enabled", "false"); #not needed, as you can't start the engine with preheater enabled, nor enable the preheater anyway when engine running, or aircraft moving
        setprop("/controls/fuel/tank[0]/fill-up", 0);
        setprop("/controls/fuel/tank[1]/fill-up", 0);
    }

    settimer(ad, 0.1);
}
init = func {
   settimer(ad, 0.0);
}

init();



##########################################
# Click Sounds
##########################################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/model/c182s/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after 0.2 seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

##########################################
# Thunder Sound
##########################################

var speed_of_sound = func (t, re) {
    # Compute speed of sound in m/s
    #
    # t = temperature in Celsius
    # re = amount of water vapor in the air

    # Compute virtual temperature using mixing ratio (amount of water vapor)
    # Ratio of gas constants of dry air and water vapor: 287.058 / 461.5 = 0.622
    var T = 273.15 + t;
    var v_T = T * (1 + re/0.622)/(1 + re);

    # Compute speed of sound using adiabatic index, gas constant of air,
    # and virtual temperature in Kelvin.
    return math.sqrt(1.4 * 287.058 * v_T);
};

var thunder = func (name) {
    var thunderCalls = 0;

    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x, 2) + math.pow(lightning_pos_y, 2));

    # On the ground, thunder can be heard up to 16 km. Increase this value
    # a bit because the aircraft is usually in the air.
    if (lightning_distance > 20000)
        return;

    var t = getprop("/environment/temperature-degc");
    var re = getprop("/environment/relative-humidity") / 100;
    var delay_seconds = lightning_distance / speed_of_sound(t, re);

    # Maximum volume at 5000 meter
    var lightning_distance_norm = std.min(1.0, 1 / math.pow(lightning_distance / 5000.0, 2));

    settimer(func {
        var thunder1 = getprop("/sim/model/c182s/sound/click-thunder1");
        var thunder2 = getprop("/sim/model/c182s/sound/click-thunder2");
        var thunder3 = getprop("/sim/model/c182s/sound/click-thunder3");

        if (!thunder1) {
            thunderCalls = 1;
            setprop("/sim/model/c182s/sound/lightning/dist1", lightning_distance_norm);
        }
        else if (!thunder2) {
            thunderCalls = 2;
            setprop("/sim/model/c182s/sound/lightning/dist2", lightning_distance_norm);
        }
        else if (!thunder3) {
            thunderCalls = 3;
            setprop("/sim/model/c182s/sound/lightning/dist3", lightning_distance_norm);
        }
        else
            return;

        # Play the sound (sound files are about 9 seconds)
        click("thunder" ~ thunderCalls, 9.0, 0);
    }, delay_seconds);
};


############################################
# Engine coughing sound
############################################

# Play coughing sound when engine was killed
setlistener("/engines/engine[0]/killed", func (node) {
    if (node.getValue() and getprop("/fdm/jsbsim/propulsion/engine/set-running")) {
        click("coughing-engine-sound", 0.7, 0);
    };
});



##########################################
# Thunder sound
##########################################
setlistener("/sim/signals/fdm-initialized", func {
    # Listening for lightning strikes
    setlistener("/environment/lightning/lightning-pos-y", thunder);
});


##########################################
#Icing graphic helper
##########################################
var icinggraphic = func {
    var ice= getprop("/fdm/jsbsim/ice/wing") or 0;
    setprop("/fdm/jsbsim/ice/graphic", (ice *2.55));


settimer(icinggraphic, 0.1);
}
icinggraphic();





##########################################
# Preflight control surface check: left aileron
##########################################
var control_surface_check_left_aileron = func {
    var auto_coordination = getprop("/controls/flight/auto-coordination");
    setprop("/controls/flight/auto-coordination", 0);
    interpolate("/controls/flight/aileron", 1.0, 0.5, -1.0, 1.0, 0.0, 0.5);
    settimer(func(){
        setprop("/controls/flight/auto-coordination", auto_coordination);
    }, 2.0);
};

##########################################
# Preflight control surface check: right aileron
##########################################
var control_surface_check_right_aileron = func {
    var auto_coordination = getprop("/controls/flight/auto-coordination");
    setprop("/controls/flight/auto-coordination", 0);
    interpolate("/controls/flight/aileron", -1.0, 0.5, 1.0, 1.0, 0.0, 0.5);
    settimer(func(){
        setprop("/controls/flight/auto-coordination", auto_coordination);
    }, 2.0);
};

##########################################
# Preflight control surface check: elevator
##########################################
var control_surface_check_elevator = func {
    interpolate("/controls/flight/elevator", 1.0, 0.8, -1.0, 1.6, 0.0, 0.8);
};

##########################################
# Preflight control surface check: rudder
##########################################
var control_surface_check_rudder = func {
    interpolate("/controls/flight/rudder", -1.0, 0.8, 1.0, 1.6, 0.0, 0.8);
};



###########################################
# FOG AND FROST stuff
###########################################

var update_cabintempchange_text = func {
    # Sets a verbally text based on temperature change.
    var txtp = "/fdm/jsbsim/heat/cabin-temperature-change-text";
    var chng = getprop("/fdm/jsbsim/heat/cabin-air-transfer-total") or 0;

    if (chng < -3) {         setprop(txtp, "cooling down quickly");
    } else if (chng <= -1) { setprop(txtp, "cooling down");
    } else if (chng >= 3) {  setprop(txtp, "heating up quickly");
    } else if (chng >= 1) {  setprop(txtp, "heating up");
    } else {                 setprop(txtp, "");
    }
};
var cabin_tempchangetxt_updateloop = maketimer(5.0, update_cabintempchange_text); # update text with some lag

var update_cabintemp_humidity_text = func {
    # Sets a verbally text based on temperature.
    # TODO: should be enhanced to perceived temperature some time because humidity plays a role in the perception of temperatue
    var txtp    = "/fdm/jsbsim/heat/cabin-temperature-text";
    var txtpsht = "/fdm/jsbsim/heat/cabin-temperature-text-short";
    var temp    = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc") or 0;
    var tchng   = getprop("/fdm/jsbsim/heat/cabin-temperature-change-text") or "";
    if (tchng != "") tchng = " (" ~ tchng ~ ")";

    if (temp < 0) {           setprop(txtp, "My fingers are freezing" ~ tchng);             setprop(txtpsht, "frosty");
    } else if (temp <= 10) {  setprop(txtp, "A little bit fresh here" ~ tchng);             setprop(txtpsht, "chilly");
    } else if (temp <= 18) {  setprop(txtp, "A little too cold here for my taste" ~ tchng); setprop(txtpsht, "cool");
    } else if (temp <= 25) {  setprop(txtp, "I feel comfortably warm now" ~ tchng);         setprop(txtpsht, "comfortable");
    } else if (temp <= 30) {  setprop(txtp, "It is getting hot in here" ~ tchng);           setprop(txtpsht, "warm");
    } else {                  setprop(txtp, "Uh, are we taking a sauna in here?" ~ tchng);  setprop(txtpsht, "hot");
    }

    # Sets a verbally text based on humidity.
    var txth = "/fdm/jsbsim/heat/cabin-humidity-text";
    var hum  = getprop("/fdm/jsbsim/heat/cabin-relative-humidity") or 0;

    if (hum < 40) {           setprop(txth, "The Air feels very dry.");
    } else if (hum <= 70) {   setprop(txth, "The Air feels comfortable.");
    } else {                  setprop(txth, "The Air feels very dampy.");
    }
};
var cabin_temp_updateloop = maketimer(15.0, update_cabintemp_humidity_text); # update text all 15secs at most

var lastTemperaturePrinted = -100; # to prevent spam with outside-spec loop; but always print the first time
var print_cabintemp_text = func {
    # Log changed temperature feelings
    if (getprop("/sim/model/c182s/enable-fog-frost") and getprop("/sim/model/c182s/enable-fog-frost-msgs")) {
        var temp      = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc") or 0;
        var temp_txt  = getprop("/fdm/jsbsim/heat/cabin-temperature-text");
        if (temp_txt) {
            var txt       = "Cabin temperature: " ~ temp_txt;
            if (temp < 0) {           logger.screen.red(txt);
            } else if (temp <= 10) {  logger.screen.red(txt);
            } else if (temp <= 18) {  logger.screen.white(txt);
            } else if (temp <= 25) {  logger.screen.green(txt);
            } else if (temp <= 30) {  logger.screen.white(txt);
            } else {                  logger.screen.red(txt);
            }

            lastTemperaturePrinted = getprop("/sim/time/elapsed-sec");
        }
    }
};
setlistener("/fdm/jsbsim/heat/cabin-temperature-text", print_cabintemp_text, 1, 0);

var cabin_temp_outsideSpecComplainLoop = maketimer(30.0, func () {
    # Log repeatedly when temperature is way outside the comfort zone and needs attention
    if (getprop("/sim/model/c182s/enable-fog-frost")) {
        var temp = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc") or 0;
        if (temp <= 18 or temp > 30) {
            if (getprop("/sim/time/elapsed-sec") >= lastTemperaturePrinted + 5) {  #to avoid spam conflict with normal loop
                print_cabintemp_text();
            }
        }
    }
});

# Deactivade because humidity sensing is not precise/notable to humans (see: https://github.com/HHS81/c182s/pull/228#issuecomment-354659510 )
#var lastHumidityPrinted = -100; # to prevent spam with outside-spec loop; but always print the first time
#var print_cabinhumidity_text = func {
#    # Log changed temperature feelings
#    if (getprop("/sim/model/c182s/enable-fog-frost")) {
#        var hum     = getprop("/fdm/jsbsim/heat/cabin-relative-humidity") or 0;
#        var hum_txt = getprop("/fdm/jsbsim/heat/cabin-humidity-text") or 0;
#        var txt     = "Cabin humidity: " ~ hum_txt;
#        if (hum_txt) {
#            if (hum < 40) {          logger.screen.red(txt);
#            } else if (hum <= 70) {  logger.screen.white(txt);
#            } else {                 logger.screen.red(txt);
#            }
#
#            lastHumidityPrinted = getprop("/sim/time/elapsed-sec");
#        }
#    }
#};
#setlistener("/fdm/jsbsim/heat/cabin-humidity-text", print_cabinhumidity_text, 1, 0);
#
#var cabin_hum_outsideSpecComplainLoop = maketimer(30.0, func () {
#    # Log repeatedly when temperature is way outside the comfort zone and needs attention
#    if (getprop("/sim/model/c182s/enable-fog-frost")) {
#        var hum = getprop("/fdm/jsbsim/heat/cabin-relative-humidity") or 0;
#        if (hum >70) {
#            if (getprop("/sim/time/elapsed-sec") >= lastHumidityPrinted + 5) {  #to avoid spam conflict with normal loop
#                print_cabinhumidity_text();
#            }
#        }
#    }
#});

# Init cabin_temp core loops 10s after sim start
settimer(func(){
    cabin_temp_updateloop.start();
    cabin_temp_outsideSpecComplainLoop.start();
#    cabin_hum_outsideSpecComplainLoop.start();
    cabin_tempchangetxt_updateloop.start();
}, 2.0);

setlistener("sim/current-view/internal", func (node) {
    #log when view switches to "internal"
    if (node.getValue()) {
        if (getprop("/sim/time/elapsed-sec") >= lastTemperaturePrinted + 5) {  #to avoid spam conflict with normal loop
            print_cabintemp_text();
        }
#        if (getprop("/sim/time/elapsed-sec") >= lastHumidityPrinted + 5) {  #to avoid spam conflict with normal loop
#            print_cabinhumidity_text();
#        }
    }
}, 1, 0);

var log_fog_frost = func {
    # log that frost/fog appeared and what to do against it
    if (getprop("/sim/model/c182s/enable-fog-frost") and getprop("/sim/model/c182s/enable-fog-frost-msgs")) {
        logger.screen.white("Wait until fog/frost clears up or engage defroster or decrease cabin air temperature");
    }
};

var fog_frost_timer = maketimer(30.0, log_fog_frost); # check fog/frost every 30s

setlistener("/sim/model/c182s/fog-or-frost-increasing", func (node) {
    #log when frost/fog is here
    if (node.getValue()) {
        log_fog_frost();
        fog_frost_timer.start();
    }
    else {
        fog_frost_timer.stop();
    }
}, 1, 0);


##########
# Magneto key bindings
# called by pressing { or } (see redefinition in c182-set.xml)
##########
var stepMagnetos = func(p) {
    var keypos = getprop("/controls/switches/magnetos");
    var magpos = getprop("controls/engines/engine/magnetos");
    #print("stepMagnetos called with p=" ~ p ~ "; keypos=" ~ keypos ~ "; magpos=" ~ magpos);

    if (p == -1 and keypos <= 3 and keypos > 0) {
        # mag decrease
        var tgt_value = keypos - 1;
        setprop("/controls/switches/magnetos", tgt_value);   # triggers an update listener
    }
    if (p == 1 and keypos < 3 and keypos >= 0) {
        # mag increase
        var tgt_value = keypos + 1;
        setprop("/controls/switches/magnetos", tgt_value);   # triggers an update listener
    }

}


###########
# Handle seat position
###########
# called from interior-model from seat
var updateSeatPosition = func(amount_in_m=0) {
    var seat_offset = getprop("/sim/model/c182s/cockpit/FrontSeatL-setting-m") or 0;
    #print("updateSeatPosition called with p=" ~ amount_in_m ~ ", seat_offset=" ~ seat_offset);
    if (amount_in_m == 0) {
        # initialize
        amount_in_m = seat_offset;
    } else if ( (amount_in_m > 0 and seat_offset < 0.15) or (amount_in_m < 0 and seat_offset > -0.15) ) {
        # adjust if inside seat limits
        seat_offset = seat_offset + amount_in_m;
        setprop("/sim/model/c182s/cockpit/FrontSeatL-setting-m", sprintf("%.2f", seat_offset));
    } else {
        # limits were hit
        amount_in_m = 0;
    }
    
    var view_default = getprop("/sim/view/config/z-offset-m");
    var view_current = getprop("/sim/current-view/z-offset-m");
    setprop("/sim/view/config/z-offset-m", view_default + amount_in_m);
    setprop("/sim/current-view/z-offset-m", view_current + amount_in_m);
}
updateSeatPosition(); # init seat position


##########
# Handle Yoke transparency
##########
var updateYokeTransparency = func() {
    var hide = getprop("/sim/model/hide-yoke") or 0;
    if (hide == 1) {
        alpha = getprop("sim/model/hide-yoke-alpha-cmd");
    } else {
        alpha = 1;
    }
    setprop("/sim/model/hide-yoke-alpha", alpha);
}
setlistener("/sim/model/hide-yoke", updateYokeTransparency, 1, 0);
setlistener("/sim/model/hide-yoke-alpha-cmd", updateYokeTransparency, 1, 0);


##########
# Parachuters
##########
var parajump_transferToStrutTimeSecs = 5;
setprop("/fdm/jsbsim/external_reactions/parachuterOnStrut/magnitude", 0.0);
var parajump = func(who) {
    var parajump_transferToStrutTimeSecs = 5;
    #print("DBG: parajump("~who~") called");
    
    var agl_ft = getprop("/position/altitude-agl-m");
    if (agl_ft < 150) {
        print("Altitude too low for jump");
        setprop("/sim/messages/copilot", "Altitude too low for jump!");
        return;
    }
    
    var jumper_name     = getprop("/payload/weight["~who~"]/name");
    var jumper_weight_p = "/payload/weight["~who~"]/weight-lb";
    var jumper_weight   = getprop("/payload/weight["~who~"]/weight-lb");
    var strut_weight_p  = "/fdm/jsbsim/external_reactions/parachuterOnStrut/magnitude";
    if (getprop(strut_weight_p) > 0) {
        print("Already a parajumper on the strut - please wait!");
        
    } else if (jumper_weight > 0) {
        # Transfer the jumpter to the strut, then release him
        
        setprop("/sim/messages/pilot", jumper_name ~ ", Go!");
        print("Parajumper " ~ jumper_name ~ " (" ~ math.round(jumper_weight) ~ " lbs) transfers to strut!");
        interpolate(strut_weight_p, jumper_weight, parajump_transferToStrutTimeSecs);
        interpolate(jumper_weight_p, 0, parajump_transferToStrutTimeSecs);
        
        # Release jumper (and trigger spawn of jumper submodel)
        var chute_timer = maketimer(parajump_transferToStrutTimeSecs+1, func(){
            print("Parajumper " ~ jumper_name ~ " jumped!");
            setprop("/sim/model/c182s/parachuters/trigger-jump", 1);
            settimer(func(){ setprop("/sim/model/c182s/parachuters/trigger-jump", 0);}, 0.25);
            #setprop(jumper_weight_p, 0);
            setprop(strut_weight_p, 0);
        });
        chute_timer.singleShot = 1; # timer will only be run once
        chute_timer.start();
        
    } else {
        print("Parajumper " ~ jumper_name ~ " not in the plane.");
    }
}

var pax_order = [3,2,1];
var pax_i = 0;
var paxjumptimer = maketimer(parajump_transferToStrutTimeSecs+2, func() {
    if (pax_i >= size(pax_order) ) {
        pax_i = 0;
        setprop("/sim/model/c182s/parachuters/trigger-running", 0);
        #print("Parajumper jump_all: all out!");
        paxjumptimer.stop();
    } else {
        #print("Parajumper jump_all: " ~ pax_i ~ " (slot="~pax_order[pax_i]~") triggered to jump");
        parajump(pax_order[pax_i]);
        pax_i = pax_i + 1;
    }
});
var parajump_all = func() {
    # drops out all the parajumpers; called from GUI item
    if (paxjumptimer.isRunning) return;
    setprop("/sim/model/c182s/parachuters/trigger-running", 1);
    paxjumptimer.start();
    setprop("/sim/messages/pilot", "Prepare to jump!");
}

# Detect local jump and spawn model
setlistener("/sim/model/c182s/parachuters/trigger-jump", func(node) {
    if (node.getValue() == 1) mp_parachuterjump_spawn(props.globals.getNode("/"));
}, 0, 0);


##########
# FGComands for bindings
##########
var c182_cowlflap_step = func(v) {
    var cowlflaps = props.globals.getNode("/controls/engines/engine/cowl-flaps-norm");
    var next = cowlflaps.getValue() + v;
    if (next > 1.0) next = 1.0;
    if (next < 0.0) next = 0.0;
    cowlflaps.setValue(next);
}
addcommand("c182_cowlflap_step_open", func {
    c182_cowlflap_step(0.25);
});
addcommand("c182_cowlflap_step_close", func {
    c182_cowlflap_step(-0.25);
});


###########
# INIT of Aircraft
# (states are initialized in separate nasal script!)
###########

setlistener("/sim/signals/fdm-initialized", func {
    # Fuel contamination
    init_fuel_contamination();


    # Reapply tiedowns/chocks to current position in case they
    # were engaged at startup (this avoids the weird aircraft dance)
    # note: this is a little hacky and probably should be solved cleanly!
    if (getprop("/sim/model/c182s/securing/tiedownL-visible")) {
        setprop("/sim/model/c182s/securing/tiedownL-visible", 0);
        settimer(func(){ setprop("/sim/model/c182s/securing/tiedownL-visible", 1);}, 0.25);
    }
    if (getprop("/sim/model/c182s/securing/tiedownR-visible")) {
        setprop("/sim/model/c182s/securing/tiedownR-visible", 0);
        settimer(func(){ setprop("/sim/model/c182s/securing/tiedownR-visible", 1);}, 0.25);
    }
    if (getprop("/sim/model/c182s/securing/tiedownT-visible")) {
        setprop("/sim/model/c182s/securing/tiedownT-visible", 0);
        settimer(func(){ setprop("/sim/model/c182s/securing/tiedownT-visible", 1);}, 0.25);
    }
    if (getprop("/sim/chocks001/enable")) {
        setprop("/sim/chocks001/enable", 0);
        settimer(func(){ setprop("/sim/chocks001/enable", 1);}, 0.25);
    }
    if (getprop("/sim/chocks002/enable")) {
        setprop("/sim/chocks002/enable", 0);
        settimer(func(){ setprop("/sim/chocks002/enable", 1);}, 0.25);
    }
    if (getprop("/sim/chocks003/enable")) {
        setprop("/sim/chocks003/enable", 0);
        settimer(func(){ setprop("/sim/chocks003/enable", 1);}, 0.25);
    }

    # Reapply pitot cover so jsbsim has a chance to set the ASI to 0 when parked
    # (jsbsim needs a brief time to stabilize the values)
    if (getprop("/sim/model/c182s/securing/pitot-cover-visible")) {
        setprop("/sim/model/c182s/securing/pitot-cover-visible", 0);
        settimer(func(){ setprop("/sim/model/c182s/securing/pitot-cover-visible", 1);}, 0.25);
    }
    
    # Load correct passenger model stances for the planes configuration
    setlistener("/sim/model/c182s/parachuters/aircraft-mod-enabled", func (node) {
        var pax_modelcfg = node.getBoolValue()? "humans-pax-parachuters.xml" : "humans.xml";
        io.read_properties ("Aircraft/c182s/Models/Human/"~pax_modelcfg, props.globals.getNode("/sim/model"));
    }, 1, 0);
    
    
    #
    # FGCamera compatibility (https://wiki.flightgear.org/FGCamera#Aircraft_integration_API)
    #  - Open the door on the C182S/T when getting out or in:
    #
    if (addons.isAddonLoaded("a.marius.FGCamera")) {
        fgcamera.walker.getOutCallback = func {
            fgcamera.walker.getOutTime = getprop("/sim/model/door-positions/DoorL/opened") == 0 ? 2 : 0;
            c182s.DoorL.open();
        };

        fgcamera.walker.getInCallback = func {
            view.setViewByIndex(110); # so we stay outside (under the hood we are already switched one frame into the pilot seat, which we must roll back)
            fgcamera.walker.getInTime = getprop("/sim/model/door-positions/DoorL/opened") == 0 ? 2 : 0;
            #c182s.DoorL.close();
        };
        print("C182 FGCamera integration loaded");
    }

});

# generate legacy author property (used by the about dialog)
var authors = [];
foreach (var author; props.globals.getNode("/sim/authors").getChildren()) {
    var name = author.getNode("name");
    var nick = author.getNode("nick");
    var desc = author.getNode("description");
    if (name != nil) {
        append(authors, name.getValue());
    } else if (nick != nil) {
       append(authors, nick.getValue());
    }
}
setprop("/sim/author",string.join(", ", authors));
