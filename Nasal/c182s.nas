
# liveries =========================================================
aircraft.livery.init("Aircraft/c182s/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");

#wheel chocks======================================================
#to-do:
#credits

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
#to-do:
#credits

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
#to-do:
#credits

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
#to-do:
#credits
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
#to-do:
#credits
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
#to-do:
#credits
var EngPreHeat_model = {
       index:   0,
       add:   func {
                          #print("EngPreHeat_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var fueltanktrailer = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());
				
		geo.put_model("Aircraft/c182s/Models/Exterior/RedDragonEnginePreHeater.ac", fueltanktrailer,
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
ad = func {
    GROUNDSPEED = getprop("/velocities/groundspeed-kt") or 0; 

    if (GROUNDSPEED > 0.1) {
        setprop("/controls/electric/external-power", "false");
        setprop("/controls/electric/TEST", "true");
        setprop("/engines/engine/external-heat/enabled", "false");
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
var repair_damage = func {
    print("Repairing damage...");
    reset_fuel_contamination();
    setprop("/engines/engine[0]/kill-engine", 0.0);
    setprop("/engines/engine[0]/crashed", 0.0);
    electrical.reset_battery_and_circuit_breakers();
    setprop("/engines/engine[0]/oil-level", 8.0);
};




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
