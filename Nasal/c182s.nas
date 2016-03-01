
# liveries =========================================================
aircraft.livery.init("Aircraft/c182/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");

#wheel chocks======================================================
#to-do:
#credits

var chocks_model = {
       index:   0,
       add:   func {
                          print("chocks_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		      
		var chocks = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());
				
		geo.put_model("Aircraft/c182/Models/Exterior/chock.ac", chocks,
				props.globals.getNode("/orientation/heading-deg").getValue());
					 me.index = i;	
          },
	  
       remove:   func {
                print("chocks_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/chocks/enable", func(n) {
		if (n.getValue()) {
				chocks_model.add();
		} else  {
			chocks_model.remove();
		}
	});
}
settimer(init_common,0);


#safety-cones======================================================
#to-do:
#credits

var cones_model = {
       index:   0,
       add:   func {
                          print("cones_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var cones = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());
				
		geo.put_model("Aircraft/c182/Models/Exterior/safety-cones.ac", cones,
				props.globals.getNode("/orientation/heading-deg").getValue());
				 me.index = i;
          },
	  
       remove:   func {
                print("cones_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/cones/enable", func(n) {
		if (n.getValue()) {
				cones_model.add();
		} else  {
			cones_model.remove();
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
                          print("gpu_model.add");
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
                print("gpu_model.remove");
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
                          print("ladder_model.add");
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
                print("ladder_model.remove");
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
                          print("fueltanktrailer_model.add");
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
                print("fueltanktrailer_model.remove");
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



	



