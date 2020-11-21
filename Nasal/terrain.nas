
var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 0);

#Following maps dust color and strength
var dustcolor_map = {
#zero dust or only wet spray
BuiltUpCover: 0.0, 
Town: 0.0, 
Freeway:0.0, 
pa_taxiway : 0.0, 
pa_tiedown: 0.0, 
pc_taxiway: 0.0, 
pc_tiedown: 0.0, 
Rock: 0.0, 
Construction: 0.0, 

#green dust or wet spray
BarrenCover:1.0, 
HerbTundraCover: 1.0, 
GrassCover: 1.0, 
CropGrassCover: 1.0, 
EvergreenBroadCover: 1.0, 
EvergreenNeedleCover: 1.0, 
Grass: 1.0, 
Grassland: 1.0,
GolfCourse: 1.0,

#water spray
Ocean: 2.0, 
Marsh: 2.0, 
Lake: 2.0, 
IntermittentStream: 2.0,

#brown dust or water spray
ShrubCover: 3.0, 
Shrub: 3.0, 
Landmass: 3.0, 
CropWoodCover: 3.0, 
MixedForestCover: 3.0, 
DryCropPastureCover: 3.0, 
MixedCropPastureCover: 3.0, 
MixedCrop: 3.0, 
ComplexCrop: 3.0, 
Sand: 3.0, 
IrrCropPastureCover: 3.0, 
DeciduousBroadCover: 3.0, 
DeciduousNeedleCover: 3.0, 
NaturalCrop: 3.0,
DryLake: 3.0, 
DryCrop: 3.0,

#white dust or wet spray
Glacier: 4.0, 
SnowCover: 4.0, 
PackIce: 4.0,

#all others
Bog: 5.0, 
Littoral: 5.0, 
Lava: 5.0, 
};


terrain_survol = func {

dust = props.globals.getNode("fdm/jsbsim/environment/dust", 1);
dust.setValue(0);

dust_r = props.globals.getNode("/fdm/jsbsim/effects/dust-r", 1);
dust_g = props.globals.getNode("/fdm/jsbsim/effects/dust-g", 1);
dust_b = props.globals.getNode("/fdm/jsbsim/effects/dust-b", 1);
dust_s = props.globals.getNode("/fdm/jsbsim/effects/dust-s", 1);

snow = props.globals.getNode("fdm/jsbsim/environment/snow", 1);


var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);


 if (info != nil) {
    if (info[0] != nil){
       setprop("fdm/jsbsim/environment/terrain-hight",info[0]);

if (contains(dustcolor_map,info[1].names[0])) 
				{      setprop("fdm/jsbsim/environment/dust",dustcolor_map[info[1].names[0]]);}
			else 
				{setprop("fdm/jsbsim/environment/dust",0.0);}

    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("fdm/jsbsim/environment/terrain-undefined",0);
        setprop("fdm/jsbsim/environment/terrain-solid",info[1].solid);


    }
   
      if (info[1].names !=nil)
       setprop("fdm/jsbsim/environment/terrain-names",info[1].names[0]);


    }else{
setprop("fdm/jsbsim/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
 
    setprop("fdm/jsbsim/environment/terrain-names","unknown");
    }
    
#### set dust colors

dust = getprop("/fdm/jsbsim/environment/dust") or 0;

thrust =  getprop("fdm/jsbsim/propulsion/engine/thrust-lbs") or 0;
wetness = getprop ("environment/surface/wetness");
agl = getprop ("position/altitude-agl-m") or 1;

alm = getprop ("fdm/jsbsim/position/h-sl-meters") or 0;
snowm = getprop ("environment/snow-level-m") or 0;

if (alm > snowm)
{
snow.setValue(1);}
else{
snow.setValue(0);
}

s = getprop ("fdm/jsbsim/environment/snow") or 0;


if (dust == 0){
dust_r.setValue(s+ wetness + 0.1);
dust_g.setValue(s+ wetness + 0.1);
dust_b.setValue(s+ wetness + 0.1);
dust_s.setValue((1/agl) * (s + wetness + 0 * (thrust/900)));
}elsif(dust == 1){
dust_r.setValue(s+ wetness + 0);
dust_g.setValue(s+ wetness + 0.2);
dust_b.setValue(s+ wetness + 0);
dust_s.setValue((1/agl) * (s + wetness + 0.5 * (thrust/900)));
}elsif(dust == 2){
dust_r.setValue(s+ wetness + 0.9);
dust_g.setValue(s+ wetness + 0.9);
dust_b.setValue(s+ wetness + 1);
dust_s.setValue((1/agl) * (s + wetness + 1.0 * (thrust/900)));
}elsif(dust == 3){
dust_r.setValue( s+ wetness + 0.9);
dust_g.setValue(s+ wetness + 0.5);
dust_b.setValue(s+ wetness + 0);
dust_s.setValue((1/agl) * (s + wetness + 1.0 * (thrust/900)));
}elsif(dust == 4){
dust_r.setValue( s+ wetness + 0.9);
dust_g.setValue(s+ wetness + 0.9);
dust_b.setValue(s+ wetness + 1);
dust_s.setValue((1/agl) * (s + wetness + 2.0 * (thrust/900)));
}else{
dust_r.setValue(s+ wetness + 1);
dust_g.setValue(s+ wetness + 1);
dust_b.setValue(s+ wetness + 1);
dust_s.setValue((1/agl) * (s + wetness + 0 * (thrust/900)));
}


settimer (terrain_survol, 0.1);
}

terrain_survol();


