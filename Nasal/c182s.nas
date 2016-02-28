
# liveries =========================================================
aircraft.livery.init("Aircraft/c182/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");

#wheel chocks======================================================
#to-do:
#credits

 var chocks_model = {
       index:   0,
       add:   func {
            

                   #print("chocks_model.add");

             var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		      
		
		      
		var heading = getprop("/orientation/heading-deg");
		var pitch = getprop("/orientation/pitch-deg");
		var roll = getprop("/orientation/roll-deg");

		var lat = getprop("/position/latitude-deg");
		var long = getprop("/position/longitude-deg");
		var alt = getprop("/position/altitude-ft");
		

		setprop("sim/chocks/latitude-deg", lat);
		setprop("sim/chocks/longitude-deg", long);
		setprop("sim/chocks/altitude-ft", (alt -3.8513828));
		setprop("sim/chocks/model-heading-deg", (heading ));
		setprop("sim/chocks/pitch-deg", pitch);
		setprop("sim/chocks/roll-deg", roll);
		
                
                props.globals.getNode("models/model[" ~ i ~ "]/path", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/longitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/latitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/elevation-ft-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/heading-deg-prop", 1);
                
                setprop ("models/model[" ~ i ~ "]/path", "Aircraft/c182/Models/Exterior/chock.ac");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/chocks/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/chocks/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/chocks/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/chocks/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
                me.index = i;
             
          },
       remove:   func {
             
                #print("chocks_model.remove");
             
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
            

                   #print("cones_model.add");

             var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		      
		
		      
		var heading = getprop("/orientation/heading-deg");
		var pitch = getprop("/orientation/pitch-deg");
		var roll = getprop("/orientation/roll-deg");

		var lat = getprop("/position/latitude-deg");
		var long = getprop("/position/longitude-deg");
		var alt = getprop("/position/altitude-ft");
		

		setprop("sim/cones/latitude-deg", lat);
		setprop("sim/cones/longitude-deg", long);
		setprop("sim/cones/altitude-ft", (alt -3.8513828));
		setprop("sim/cones/model-heading-deg", (heading ));
		setprop("sim/cones/pitch-deg", pitch);
		setprop("sim/cones/roll-deg", roll);
		
                
                props.globals.getNode("models/model[" ~ i ~ "]/path", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/longitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/latitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/elevation-ft-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/heading-deg-prop", 1);
                
                setprop ("models/model[" ~ i ~ "]/path", "Aircraft/c182/Models/Exterior/safety-cones.ac");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/cones/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/cones/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/cones/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/cones/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
                me.index = i;
             
          },
       remove:   func {
             
                #print("cones_model.remove");
             
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
            

                   #print("gpu_model.add");

             var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		      
		
		      
		var heading = getprop("/orientation/heading-deg");
		var pitch = getprop("/orientation/pitch-deg");
		var roll = getprop("/orientation/roll-deg");

		var lat = getprop("/position/latitude-deg");
		var long = getprop("/position/longitude-deg");
		var alt = getprop("/position/altitude-ft");
		

		setprop("sim/gpu/latitude-deg", lat);
		setprop("sim/gpu/longitude-deg", long);
		setprop("sim/gpu/altitude-ft", (alt -3.8513828));
		setprop("sim/gpu/model-heading-deg", (heading ));
		setprop("sim/gpu/pitch-deg", pitch);
		setprop("sim/gpu/roll-deg", roll);
		
                
                props.globals.getNode("models/model[" ~ i ~ "]/path", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/longitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/latitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/elevation-ft-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/heading-deg-prop", 1);
                
                setprop ("models/model[" ~ i ~ "]/path", "Aircraft/c182/Models/Exterior/external-power.xml");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/gpu/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/gpu/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/gpu/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/gpu/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
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
		      
		
		      
		var heading = getprop("/orientation/heading-deg");
		var pitch = getprop("/orientation/pitch-deg");
		var roll = getprop("/orientation/roll-deg");

		var lat = getprop("/position/latitude-deg");
		var long = getprop("/position/longitude-deg");
		var alt = getprop("/position/altitude-ft");
		

		setprop("sim/ladder/latitude-deg", lat);
		setprop("sim/ladder/longitude-deg", long);
		setprop("sim/ladder/altitude-ft", (alt -3.8513828));
		setprop("sim/ladder/model-heading-deg", (heading ));
		setprop("sim/ladder/pitch-deg", pitch);
		setprop("sim/ladder/roll-deg", roll);
		
                
                props.globals.getNode("models/model[" ~ i ~ "]/path", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/longitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/latitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/elevation-ft-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/heading-deg-prop", 1);
                

		setprop ("models/model[" ~ i ~ "]/path", "Aircraft/c182/Models/Exterior/ladder.xml");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/ladder/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/ladder/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/ladder/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/ladder/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
                me.index = i;
             
          },
       remove:   func {
             
                #print("test_model.remove");
             
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

#test======================================================
#to-do:
#credits

	
 var test_model = {
       index:   0,
       add:   func {
                          print("test_model.add");
  var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
		var test = geo.aircraft_position().set_alt(
				props.globals.getNode("/position/ground-elev-m").getValue());
				
		geo.put_model("Aircraft/c182/Models/Exterior/external-power.xml", test,
				props.globals.getNode("/orientation/heading-deg").getValue());
          },
	  
       remove:   func {
                print("test_model.remove");
             props.globals.getNode("/models", 1).removeChild("model", me.index);
          },
};

var init_common = func {
	setlistener("/sim/test/enable", func(n) {
		if (n.getValue()) {
				test_model.add();
		} else  {
			test_model.remove();
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



	



