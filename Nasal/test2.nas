#to-do:
#credits

 var chocks_model = {
       index:   0,
       add:   func {
            
                #if (getprop("/sim/chocks/enable")) {
                   print("chocks_model.add");
                #}
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
                
                setprop ("models/model[" ~ i ~ "]/path", "Aircraft/c182/Models/Exterior/wooden-chocks.ac");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/chocks/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/chocks/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/chocks/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/chocks/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
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
