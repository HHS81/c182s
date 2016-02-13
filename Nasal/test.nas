
#var L = setlistener("/sim/model/c182/procedural-lights", func {
#    print("I can only be triggered once.");
    
 # var data = "/sim/model/cursor/";
    
 #setprop("/controls/flight/spoilers", 1.0);
 
#var heading = getprop("/orientation/heading-deg");
   #       var pitch = getprop("/orientation/pitch-deg");
   #       var roll = getprop("/orientation/roll-deg");

    #      var ac = geo.aircraft_position();
    #      ac.apply_course_distance(heading, 10);

    #      setprop(data ~ "latitude-deg", ac.lat());
    #      setprop(data ~ "longitude-deg", ac.lon());
	#setprop(data ~ "altitude-ft", ac.alt() * 3.3);
     #     setprop(data ~ "heading-deg", heading + 180);
     #     setprop(data ~ "pitch-deg", -pitch);
     #     setprop(data ~ "roll-deg", -roll);
          #settimer(update_model, 0);
	
 
 #fgcommand("add-model", props.Node.new({
      #    "path": "Aircraft/Generic/Human/Models/walker.xml",
      #    "latitude-deg-prop": data ~ "latitude-deg",
      #    "longitude-deg-prop": data ~ "longitude-deg",
      #    "elevation-ft-prop": data ~ "altitude-ft",
       #   "heading-deg-prop": data ~ "heading-deg",
       #   "pitch-deg-prop": data ~ "pitch-deg",
       #   "roll-deg-prop": data ~ "roll-deg",
  #}));
    
   # removelistener(L);
#});

 var L = setlistener("/sim/model/c182/procedural-lights", func {
 
	var data = "sim/walker/";
	var heading = getprop("/orientation/heading-deg");
          var pitch = getprop("/orientation/pitch-deg");
          var roll = getprop("/orientation/roll-deg");

          var ac = geo.aircraft_position();
          ac.apply_course_distance(heading, 10);

          setprop(data ~ "latitude-deg", 48.11676571);
          setprop(data ~ "longitude-deg", 7.361018203);
	setprop(data ~ "altitude-ft", 598.065657);
          setprop(data ~ "heading-deg", 0);
          setprop(data ~ "pitch-deg", 0);
          setprop(data ~ "roll-deg", 0);
       
           
         
                   print("walker_model.add");
                
             var manager = props.globals.getNode("/models", 1);
                var i = 0;
                for (; 1; i += 1)
                   if (manager.getChild("model", i, 0) == nil)
                      break;
                
                props.globals.getNode("models/model[" ~ i ~ "]/path", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/longitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/latitude-deg-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/elevation-ft-prop", 1);
                props.globals.getNode("models/model[" ~ i ~ "]/heading-deg-prop", 1);
                
                setprop ("models/model[" ~ i ~ "]/path", "Aircraft/Generic/Human/Models/walker.xml");
                setprop ("models/model[" ~ i ~ "]/longitude-deg-prop", "sim/walker/longitude-deg");
                setprop ("models/model[" ~ i ~ "]/latitude-deg-prop", "sim/walker/latitude-deg");
                setprop ("models/model[" ~ i ~ "]/elevation-ft-prop", "sim/walker/altitude-ft");
                setprop ("models/model[" ~ i ~ "]/heading-deg-prop", "sim/walker/model-heading-deg");
                props.globals.getNode("models/model[" ~ i ~ "]/load", 1);
                #me.index = i;
	    removelistener(L);	
	    });

       #remove:   func {
           #  if (getprop("/sim/model/c182/procedural-lights/test")) {
           #     print("walker_model.remove");
           #  }
           #  props.globals.getNode("/models", 1).removeChild("model", me.index);
             #walker_model.reset_fall();
         #};




