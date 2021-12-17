# Copyright (C) 2020  B. Hallinger
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


#
# A very basic damage system that informs the pilot of broken stuff.
# It merely serves as a placeholder until we get nice damage modelling.
#

# A simple listener-register function, so we can register listeners in a loop
var registerDamageListener = func(id, name) {
    #print("  add listener id=", id, "; name=", name);
    setlistener(id, func(node){
            if (node.getValue() > 0.1 and node.getValue()<= 0.5) {
                print(name, " damaged! (", id ,")");
                logger.screen.red(name ~ " damaged!");
            } else if (node.getValue() > 0.1) {
                print(name, " broke! (", id ,")");
                logger.screen.red(name ~ " broke!");
            }
            
            # store the value in a -saved property so we can reinitialize it in the next session
            setprop(id ~ "-saved", node.getValue());
            
            
            # Wing breakage has further consequences to:
            # - the fuel system (values comefrom Systems/damage.xml)
            # - nav/strobe lighting mounted on the wings
            var wingNode = -1;
            if (id == "/fdm/jsbsim/wing-damage/left-wing")  wingNode = 0;
            if (id == "/fdm/jsbsim/wing-damage/right-wing") wingNode = 1;
            if (wingNode > -1 and node.getValue() >= 0.25) {
                # wing structurally damaged: leak fuel
                # NOTE: the C182S has fuel bladders that should not be subject to this type of damage
                #setprop("/systems/fuel/tank["~wingNode~"]/leak-flow-rate-pps", node.getValue() * 5);
            }
            if (wingNode > -1 and node.getValue() > 0.8) {
                # wing ripped off
                setprop("/consumables/fuel/tank["~wingNode~"]/level-gal_us", 0);
                setprop("/sim/failure-manager/instrumentation/fuelIndicator["~wingNode~"]/serviceable", 0);
                setprop("/sim/failure-manager/lighting/nav-light/serviceable", 0);
                setprop("/sim/failure-manager/lighting/strobe-light/serviceable", 0);
            }
            
        }, 0, 0);
};


#################
# INIT          #
#################
setlistener("/sim/signals/fdm-initialized", func {
    
    # define the stuff that can fail and where the pilot should be notified about
    breakableThings = [
        {id:"/fdm/jsbsim/gear/unit[0]/broken",    name:"Nose gear"},
        {id:"/fdm/jsbsim/gear/unit[1]/broken",    name:"Left main gear"},
        {id:"/fdm/jsbsim/gear/unit[2]/broken",    name:"Right main gear"},
        
        {id:"/fdm/jsbsim/wing-damage/left-wing",  name:"Left wing"},
        {id:"/fdm/jsbsim/wing-damage/right-wing", name:"Right wing"},
        
        {id:"/fdm/jsbsim/wing-damage/left-flap-detector",  name:"Left flap"},
        {id:"/fdm/jsbsim/wing-damage/right-flap-detector", name:"Right flap"}
    ];
    
    var dmgdelayInit = 0.15; # delay in seconds; should be before init of aircraft states (it might repair the plane)
    var damageSystemInit = maketimer(dmgdelayInit, func(){
        
        # Initialize saved state
        foreach (thingy; breakableThings) {
            var savedDmgProp = getprop(thingy.id ~ "-saved");
            if (savedDmgProp != nil) setprop(thingy.id, savedDmgProp);
        }
        
        # Initialize listeners
        foreach (thingy; breakableThings) {
            print("C182 basic damage system: init ", thingy.name, " (curVal=",getprop(thingy.id),")");
            registerDamageListener(thingy.id, thingy.name);
        }
        
        print("C182 basic damage system initialized");
    });
    
    damageSystemInit.singleShot = 1;
    damageSystemInit.start();
});

##########################################
# system to recognize a forest
##########################################


var t = func {

var forest = getprop("/fdm/jsbsim/environment/terrain-names") or 0;
var agl = getprop("/fdm/jsbsim/position/h-agl-ft") or 0;



if  ( (forest == "MixedForestCover" or forest == "DeciduousBroadCover" or forest == "EvergreenBroadCover" or forest == "DeciduousBroadCover" or forest == "EvergreenNeedleCover" or forest == "DeciduousNeedleCover") and (agl < 95) ) {
		setprop("/fdm/jsbsim/environment/in-forest-detected", 1);
	} else{
		setprop("/fdm/jsbsim/environment/in-forest-detected", 0);
}


	settimer(t, 0.0);
}

t();


##########################################
# REPAIR DAMAGE
##########################################
var repair_damage_running = 0;
var repair_damage = func() {
    if (repair_damage_running) return;
    
    print("Repairing damage...");
    repair_damage_running = 1;
    var damagesetting_prev = getprop("fdm/jsbsim/settings/damage");
    setprop("/fdm/jsbsim/damage/repairing", 1);
    setprop("fdm/jsbsim/settings/damage", 0);

    setprop("/engines/engine[0]/kill-engine", 0.0);
    setprop("/engines/engine[0]/crashed", 0.0);
    setprop("/systems/fuel/engine-sparkplugs-iced", 0.0);
    electrical.reset_battery_and_circuit_breakers();
    FailureMgr.repair_all();
    for (var tankID=0; tankID <= 5; tankID = tankID+1) {
        setprop("/systems/fuel/tank["~tankID~"]/leak-flow-rate-pps", 0);
    }
    settimer(func(){
        setprop("fdm/jsbsim/settings/damage", damagesetting_prev);
        setprop("/fdm/jsbsim/damage/repairing", 0);
        repair_damage_running = 0;
    }, 5.0);
};
