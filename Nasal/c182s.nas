
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
				
		geo.put_model("Aircraft/c182s/Models/Exterior/fueltanktrailer.ac", fueltanktrailer,
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
DoorL = aircraft.door.new( "/sim/model/door-positions/DoorL", 2, 0 );
DoorR = aircraft.door.new( "/sim/model/door-positions/DoorR", 2, 0 );
BaggageDoor = aircraft.door.new( "/sim/model/door-positions/BaggageDoor", 2, 0 );
WindowR = aircraft.door.new( "/sim/model/door-positions/WindowR", 2, 0 );
WindowL = aircraft.door.new( "/sim/model/door-positions/WindowL", 2, 0 );

#####################
# Adjust properties when in motion
# - external electrical disconnect when groundspeed higher than 0.1ktn (replace later with distance less than 0.01...)
# - remove external heat
# - tear tiedowns when significantly off ground
ad = func {
    GROUNDSPEED = getprop("/velocities/groundspeed-kt") or 0; 
    AGL         = getprop("/position/altitude-agl-ft")  or 0;

    if (GROUNDSPEED > 0.1) {
        setprop("/controls/electric/external-power", "false");
        #setprop("/engines/engine/external-heat/enabled", "false"); #not needed, as you can't start the engine with preheater enabled, nor enable the preheater anyway when engine running, or aircraft moving
    }
    
    if (AGL > 10) {
        setprop("/sim/model/c182s/securing/tiedownT-visible", 0);
        setprop("/sim/model/c182s/securing/tiedownL-visible", 0);
        setprop("/sim/model/c182s/securing/tiedownR-visible", 0);
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


##########################################
# REPAIR DAMAGE
##########################################
var repair_damage = func() {
    print("Repairing damage...");
    setprop("/fdm/jsbsim/damage/repairing", 1);
    
    setprop("/engines/engine[0]/kill-engine", 0.0);
    setprop("/engines/engine[0]/crashed", 0.0);
    electrical.reset_battery_and_circuit_breakers();
    
    settimer(func(){ setprop("/fdm/jsbsim/damage/repairing", 0); }, 1.0);
};



###########################################
# FOG AND FROST stuff
###########################################

var update_cabintemp_humidity_text = func {
    # Sets a verbally text based on temperature.
    # TODO: should be enhanced to perceived temperature some time because humidity plays a role in the perception of temperatue
    var txtp = "/fdm/jsbsim/heat/cabin-temperature-text";
    var temp = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc") or 0;

    if (temp < 0) {           setprop(txtp, "My fingers are freezing");
    } else if (temp <= 10) {  setprop(txtp, "A little bit fresh here");
    } else if (temp <= 18) {  setprop(txtp, "A little too cold here for my taste");
    } else if (temp <= 25) {  setprop(txtp, "I feel comfortably warm now");
    } else if (temp <= 30) {  setprop(txtp, "It is getting hot in here");
    } else {                  setprop(txtp, "Uh, are we taking a sauna in here?");
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
    
});
