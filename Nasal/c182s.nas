
# liveries =========================================================
aircraft.livery.init("Aircraft/c182/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");

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
				
		geo.put_model("Aircraft/c182/Models/Exterior/chock001.ac", chocks001,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/chock002.ac", chocks002,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/chock003.ac", chocks003,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/safety-cone_R.ac", cones,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/safety-cone_L.ac", cones,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/external-power.xml", gpu,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/ladder.xml", ladder,
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
				
		geo.put_model("Aircraft/c182/Models/Exterior/fueltanktrailer.ac", fueltanktrailer,
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



	

# doors ============================================================
DoorL = aircraft.door.new( "/sim/model/door-positions/DoorL", 2, 0 );
DoorR = aircraft.door.new( "/sim/model/door-positions/DoorR", 2, 0 );
BaggageDoor = aircraft.door.new( "/sim/model/door-positions/BaggageDoor", 2, 0 );
WindowR = aircraft.door.new( "/sim/model/door-positions/WindowR", 2, 0 );
WindowL = aircraft.door.new( "/sim/model/door-positions/WindowL", 2, 0 );

#####################
# external electrical disconnect when groundspeed higher than 0.1ktn (replace later with distance less than 0.01...)
ad = func {
GROUNDSPEED = getprop("/velocities/groundspeed-kt") or 0; 

 if (GROUNDSPEED > 0.1) {
 setprop("/controls/electric/external-power", "false");
  setprop("/controls/electric/TEST", "true");
 }
   settimer(ad, 0.1);   
}
init = func {
   settimer(ad, 0.0);
}

init();	



