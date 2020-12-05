
var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 1);

terrain_survol = func {

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);




 if (info != nil) {
    if (info[0] != nil){
       setprop("fdm/jsbsim/environment/terrain-hight",info[0]);
#var terrain_hight = info[0];
#print("TERRAIN ",terrain_hight);
    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("fdm/jsbsim/environment/terrain-undefined",0);
        setprop("fdm/jsbsim/environment/terrain-solid",info[1].solid);
#var solid = info[1].solid;
#print("SOLID ",solid);

    }
       if (info[1].names !=nil)
       setprop("fdm/jsbsim/environment/terrain-names",info[1].names[0]);

#unfortunately when on carrier the info[1]  is nil,  only info[0] is valid
#var terrain_name = info[1].names[0];
#print("NAME ",terrain_name);
      #if (terrain_name == "Ocean" and terrain_hight >  min_carrier_alt)
        #setprop("fdm/jsbsim/environment/terrain-oncarrier",1);
    }else{
setprop("fdm/jsbsim/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
    setprop("fdm/jsbsim/environment/terrain-hight",0);
    setprop("fdm/jsbsim/environment/terrain-solid",1);
    setprop("fdm/jsbsim/environment/terrain-oncarrier",0);
    setprop("fdm/jsbsim/environment/terrain-light-coverage",1);
    setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
    setprop("fdm/jsbsim/environment/terrain-friction-factor",1);
    setprop("fdm/jsbsim/environment/terrain-bumpiness",0);
    setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.02);
    setprop("fdm/jsbsim/environment/terrain-names","unknown");
    }

settimer (terrain_survol, 0.1);
}


terrain_survol();


