##
# Procedural model of a Cessna 182S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#
#


##
# Initialize internal values
#

var battery = nil;
var alternator = nil;

var last_time = 0.0;

var vbus_volts = 0.0;
var ebus1_volts = 0.0;
var ebus2_volts = 0.0;


var ammeter_ave = 0.0;

var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new( "controls/lighting/strobe-state", [0.05, 0.05, 0.05, 1.7 ], strobe_switch );
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);

##
# Initialize the electrical system
#

var epu = func{
var EP  = props.globals.getNode("/controls/electric/external-power").getValue() or 0;
if (EP >0){
setprop("/systems/electrical/external_volts", 29);
}else{
setprop("/systems/electrical/external_volts", 0);
}
settimer(epu, 0.1);
}
epu();

init_electrical = func {
    battery = BatteryClass.new();
    alternator = AlternatorClass.new();
    

    # set initial switch positions
#    setprop("/controls/engines/engine[0]/master-bat", 1);
#    setprop("/controls/engines/engine[0]/master-alt", 1);
#    setprop("/controls/switches/AVMBus1", 1);
#    setprop("/controls/switches/AVMBus2", 1);
#    setprop("/systems/electrical/outputs/autopilot",0.0);
#    setprop("/controls/lighting/dome-light-r", 0);
#    setprop("/controls/lighting/dome-light-l", 0);
#    setprop("/controls/lighting/dome-exterior-light", 0);
#    setprop("/controls/lighting/instrument-lights-norm", 0);
#    setprop("/controls/lighting/glareshield-lights-norm", 0);
#    setprop("/controls/lighting/pedestal-lights-norm", 0);
#    setprop("/controls/lighting/radio-lights-norm", 0);
#set beacon
 setprop("/systems/electrical/outputs/beacon-norm", 0);
 

    # Request that the update function be called next frame
    settimer(update_electrical, 0);
    print("Electrical system initialized");
}


##
# Battery model class.
#

BatteryClass = {};
BatteryClass.new = func() {
    var obj = { parents : [BatteryClass],
                ideal_volts : 24.0,
                ideal_amps : 30.0,
                amp_hours : 12.75,
                charge_percent : getprop("/systems/electrical/battery-charge-percent") or 1.0,
                charge_amps : 7.0 };
    return obj;
}

##
# Passing in positive amps means the battery will be discharged.
# Negative amps indicates a battery charge.
#

BatteryClass.apply_load = func( amps, dt ) {
    var capacity_factor = getprop("/systems/electrical/battery-capacity-factor") or 1.0;
    var amphrs_used = amps * dt / 3600.0;
    var percent_used = amphrs_used / me.amp_hours;
    var charge_percent = me.charge_percent;
    charge_percent -= percent_used;
    if ( charge_percent < 0.0 ) {
        charge_percent = 0.0;
    } elsif ( charge_percent > 1.0 ) {
        charge_percent = 1.0;
    }
    if ((charge_percent < 0.3)and(me.charge_percent >= 0.3))
    {
        print("Warning: Low battery! Enable alternator or apply external power to recharge battery.");
    }
    me.charge_percent = charge_percent;
    setprop("/systems/electrical/battery-charge-percent", charge_percent * capacity_factor);
    # print( "battery percent = ", charge_percent);
    return me.amp_hours * charge_percent;
}

##
# Return output volts based on percent charged.  Currently based on a simple
# polynomial percent charge vs. volts function.
#

BatteryClass.get_output_volts = func {
    var x = 1.0 - me.charge_percent;
    var tmp = -(3.0 * x - 1.0);
    var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_volts * factor;
}


##
# Return output amps available.  This function is totally wrong and should be
# fixed at some point with a more sensible function based on charge percent.
# There is probably some physical limits to the number of instantaneous amps
# a battery can produce (cold cranking amps?)
#

BatteryClass.get_output_amps = func {
    var x = 1.0 - me.charge_percent;
    var tmp = -(3.0 * x - 1.0);
    var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_amps * factor;
}


##
# Alternator model class.
#

AlternatorClass = {};

AlternatorClass.new = func {
    var obj = { parents : [AlternatorClass],
                rpm_source : "/engines/engine[0]/rpm",
                rpm_threshold : 800.0,
                ideal_volts : 28.0,
                ideal_amps : 60.0 };
    setprop( obj.rpm_source, 0.0 );
    return obj;
}

##
# Computes available amps and returns remaining amps after load is applied
#

AlternatorClass.apply_load = func( amps, dt ) {
    # Scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", me.ideal_amps * factor );
    var available_amps = me.ideal_amps * factor;
    return available_amps - amps;
}

##
# Return output volts based on rpm
#

AlternatorClass.get_output_volts = func {
    # scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator volts = ", me.ideal_volts * factor );
    return me.ideal_volts * factor;
}


##
# Return output amps available based on rpm.
#

AlternatorClass.get_output_amps = func {
    # scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", ideal_amps * factor );
    return me.ideal_amps * factor;
}


##
# This is the main electrical system update function.
#

update_electrical = func {
    var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    last_time = time;

    update_virtual_bus( dt );

    # Request that the update function be called again next frame
    settimer(update_electrical, 0);
}


##
# Set the current charge instantly to 100 %.
#

BatteryClass.reset_to_full_charge = func {
    me.apply_load(-(1.0 - me.charge_percent) * me.amp_hours, 3600);
}

# Reset all breakers and battery state
var reset_battery_and_circuit_breakers = func {
    # Charge battery to 100 %
    battery.reset_to_full_charge();

    # Reset circuit breakers
#    setprop("/controls/circuit-breakers/master", 1);
#    setprop("/controls/circuit-breakers/flaps", 1);
#    setprop("/controls/circuit-breakers/pitot-heat", 1);
#    setprop("/controls/circuit-breakers/instr", 1);
#    setprop("/controls/circuit-breakers/intlt", 1);
#    setprop("/controls/circuit-breakers/navlt", 1);
#    setprop("/controls/circuit-breakers/landing", 1);
#    setprop("/controls/circuit-breakers/bcnlt", 1);
#    setprop("/controls/circuit-breakers/strobe", 1);
#    setprop("/controls/circuit-breakers/turn-coordinator", 1);
#    setprop("/controls/circuit-breakers/radio1", 1);
#    setprop("/controls/circuit-breakers/radio2", 1);
#    setprop("/controls/circuit-breakers/radio3", 1);
#    setprop("/controls/circuit-breakers/radio4", 1);
#    setprop("/controls/circuit-breakers/radio5", 1);
#    setprop("/controls/circuit-breakers/autopilot", 1);
}


##
# Model the system of relays and connections that join the battery,
# alternator, starter, master/alt switches, external power supply.
#

update_virtual_bus = func( dt ) {
    var serviceable = getprop("/systems/electrical/serviceable");
    var external_volts = 0.0;
    var load = 0.0;
    var battery_volts = 0.0;
    var alternator_volts = 0.0;
    if ( serviceable ) {
        battery_volts = battery.get_output_volts();
        alternator_volts = alternator.get_output_volts();
    }

    # switch state
    var master_bat = getprop("/controls/engines/engine[0]/master-bat");
    var master_alt = getprop("/controls/engines/engine[0]/master-alt");
    if (getprop("/controls/electric/external-power"))
    {
        external_volts = 28;
    }

    # determine power source
    var bus_volts = 0.0;
    var power_source = nil;
    if ( master_bat ) {
        bus_volts = battery_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
        power_source = "battery";
    }
    if ( master_alt and (alternator_volts > bus_volts) ) {
        bus_volts = alternator_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
        power_source = "alternator";
    }
    if ( external_volts > bus_volts ) {
        bus_volts = external_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
        power_source = "external";
    }
    # print( "virtual bus volts = ", bus_volts );

    # starter motor
    var starter_switch = getprop("controls/switches/starter");
    var starter_volts = 0.0;
    if ( starter_switch ) {
        starter_volts = bus_volts;
        load += 22;
    }
    setprop("systems/electrical/outputs/starter[0]", starter_volts);
    if (starter_volts > 22) {
        setprop("controls/engines/engine[0]/starter",1);
        setprop("controls/engines/engine[0]/magnetos",3);
    } else {
        setprop("controls/engines/engine[0]/starter",0);
    }
    
    controls.stepMagnetos = func {
        var old_value = getprop("/controls/engines/engine/magnetos");
        var new_value = std.max(0, std.min(old_value + arg[0], 3));
        setprop("/controls/engines/engine/magnetos", new_value);
    };

    # key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
    # fun fact: the key UP event can be overwriten!
    controls.startEngine = func(v = 1) {
        if (getprop("/engines/engine/external-heat/enabled") and v == 1)
        {
            setprop("/sim/messages/pilot", "Disconnect external heat before starting engine!");
            return;
        }
        if (getprop("/engines/engine[0]/running"))
        {
            setprop("/controls/switches/starter", 0);
            return;
        }
        else {
            setprop("/controls/engines/engine/magnetos", 3);
            setprop("/controls/switches/starter", v);
        }
    };


    # bus network (1. these must be called in the right order, 2. the
    # bus routine itself determins where it draws power from.)
    load += electrical_bus_1();
    load += electrical_bus_2();
    load += cross_feed_bus();
    load += avionics_bus_1();
    load += avionics_bus_2();

    # system loads and ammeter gauge
    var ammeter = 0.0;
    if ( bus_volts > 1.0 ) {
        # ammeter gauge
        if ( power_source == "battery" ) {
            ammeter = -load;
        } else {
            ammeter = battery.charge_amps;
        }
    }
    # print( "ammeter = ", ammeter );

    # charge/discharge the battery
    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
    } elsif ( bus_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
    }

    # filter ammeter needle pos
    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

    # outputs
    setprop("/systems/electrical/amps", ammeter_ave);
    setprop("/systems/electrical/volts", sprintf("%.2f", bus_volts));
    if (bus_volts > 12)
        vbus_volts = bus_volts;
    else
        vbus_volts = 0.0;

    return load;
}


electrical_bus_1 = func() {
    # we are fed from the "virtual" bus
    var bus_volts = vbus_volts;
    bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
    var load = 0.0;


    # Instrument Power
    setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);

    # Aux Fuel Pump Power
if ( bus_volts > 22 ) {
    if ( getprop("/controls/engines/engine[0]/fuel-pump") ) {
        setprop("/systems/electrical/outputs/fuel-pump", bus_volts);
        load += bus_volts / 2;
    } else {
        setprop("/systems/electrical/outputs/fuel-pump", 0.0);
    }
}
    
    var AFP = (getprop("/systems/electrical/outputs/fuel-pump"));
	if (getprop ("/controls/engines/engine[0]/fuel-pump") >0.05){
	setprop("/systems/electrical/outputs/fuel-pump-norm", AFP/24);
	}else{
	setprop("/systems/electrical/outputs/fuel-pump",0);
	setprop("/systems/electrical/outputs/fuel-pump-norm",0);
	}
	if (getprop("/systems/electrical/outputs/fuel-pump-norm") >1.0){
	setprop("/systems/electrical/outputs/fuel-pump-norm", 1.0)};
	
	if (getprop("/systems/electrical/outputs/fuel-pump-norm") <1.0){
	setprop("/systems/electrical/outputs/fuel-pump-norm-end", 1.0)
	}else{
	setprop("/systems/electrical/outputs/fuel-pump-norm-end", 0.0)};

    # Landing Light Power

    if ( getprop("/controls/lighting/landing-lights")and (bus_volts > 22) ) {
        setprop("/systems/electrical/outputs/landing-lights", bus_volts);
        load += bus_volts / 0.11;
    }
   else {
        setprop("/systems/electrical/outputs/landing-lights", 0.0 );
    }


    # Beacon Power
    

    if ( getprop("controls/lighting/beacon-state/state" ) and (bus_volts > 22) ) {
     interpolate ("/systems/electrical/outputs/beacon", bus_volts, 0.5);
	interpolate ("/systems/electrical/outputs/beacon-norm", (bus_volts/24), 0.5);
       
        load += bus_volts / 20;
    } 
else {
       
	 interpolate ("/systems/electrical/outputs/beacon", 0.0, 0.5);
	 interpolate ("/systems/electrical/outputs/beacon-norm", 0.0, 0.5);
	}

	if (getprop("/systems/electrical/outputs/beacon-norm") >1.0){
	setprop("/systems/electrical/outputs/beacon-norm", 1.0)};
	
	
	
	    



    # Flaps Power
#    if ( getprop("/controls/circuit-breakers/flaps") ) {
        setprop("/systems/electrical/outputs/flaps", bus_volts);
        load += bus_volts / 2;
#    } else {
#        setprop("/systems/electrical/outputs/flaps", 0.0);
#    }

    # register bus voltage
    ebus1_volts = bus_volts;

    # return cumulative load
    return load;
}


electrical_bus_2 = func() {
    # we are fed from the "virtual" bus
    var bus_volts = vbus_volts;
    bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
    var load = 0.0;

    # Nav Lights Power

    if ( getprop("/controls/lighting/nav-lights" )and (bus_volts > 22) ) {
        setprop("/systems/electrical/outputs/nav-lights", bus_volts);
	  setprop("/systems/electrical/outputs/nav-lights-norm", (bus_volts/24));
        load += bus_volts / 20;
    }
    else {
        setprop("/systems/electrical/outputs/nav-lights", 0.0);
	 setprop("/systems/electrical/outputs/nav-lights-norm", 0.0);
    }
  
    if (getprop("/systems/electrical/outputs/nav-lights-norm") >1.0){
	setprop("/systems/electrical/outputs/nav-lights-norm", 1.0)};
 
     
    # Strobe Lights Power
    if ( getprop("controls/lighting/strobe-state/state" ) and (bus_volts > 22) ) {
            setprop("/systems/electrical/outputs/strobe", bus_volts);
	 setprop("/systems/electrical/outputs/strobe-norm", (bus_volts/24));
        load += bus_volts / 20;
    }
    else {
        setprop("/systems/electrical/outputs/strobe", 0.0);
	setprop("/systems/electrical/outputs/strobe-norm", 0.0);
    }

    
  
    # Taxi Lights Power

    if ( getprop("/controls/lighting/taxi-light" ) and (bus_volts > 22)) {
        setprop("/systems/electrical/outputs/taxi-light", bus_volts);
        load += bus_volts / 0.22;
    } 
else {
        setprop("/systems/electrical/outputs/taxi-light", 0.0);
    }


  
    # Pitot Heat Power

    if ( getprop("/controls/anti-ice/pitot-heat" )and (bus_volts > 22) ) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
        load += bus_volts / 2.8;
    } 
else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }


    
# engine starter

    if ( getprop("/controls/engines/engine/starter" )and (bus_volts > 22)) {
        setprop("systems/electrical/outputs/starter", bus_volts);
            load += bus_volts / 0.7;
    }
    else {
        setprop("systems/electrical/outputs/starter", 0.0);
    }
  
  
    # register bus voltage
    ebus2_volts = bus_volts;

    # return cumulative load
    return load;
}


cross_feed_bus = func() {
    # we are fed from either of the electrical bus 1 or 2
    var bus_volts = ebus2_volts;
    if ( ebus1_volts > ebus2_volts ) {
        bus_volts = ebus1_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
    }

    var load = 0.0;


setprop("/systems/electrical/outputs/annunciators", bus_volts);
setprop("/systems/electrical/outputs/ecrf", bus_volts);#needed to dim lights


    if ( getprop("/controls/lighting/dome-light-r")and (bus_volts > 22)) {
        setprop("/systems/electrical/outputs/dome-light-r", bus_volts/28);
        load += bus_volts / 28;
    }
    else {
        setprop("/systems/electrical/outputs/dome-light-r", 0.0);
    }


 if ( getprop("/controls/lighting/dome-light-l")and (bus_volts > 22)) {
        setprop("/systems/electrical/outputs/dome-light-l", bus_volts/28);
        load += bus_volts / 28;
    } 
    else {
        setprop("/systems/electrical/outputs/dome-light-l", 0.0);
    }


 if ( getprop("/controls/lighting/dome-exterior-light")and (bus_volts > 22)) {
        setprop("/systems/electrical/outputs/dome-exterior-light", bus_volts/28);
        load += bus_volts / 28;
    }
    else {
        setprop("/systems/electrical/outputs/dome-exterior-light", 0.0);
    }





var IL_DIMMER = (getprop("/systems/electrical/outputs/ecrf")) * (getprop("controls/lighting/instrument-lights-norm"));
if ( bus_volts > 22 ) {
	if (getprop ("/controls/lighting/instrument-lights-norm") >0.05){
	setprop("/systems/electrical/outputs/instrument-lights",IL_DIMMER);
	setprop("/systems/electrical/outputs/instrument-lights-norm",IL_DIMMER/24);
	}
	}else{
	setprop("/systems/electrical/outputs/instrument-lights",0);
	setprop("/systems/electrical/outputs/instrument-lights-norm",0);
	}
	if (getprop("/systems/electrical/outputs/instrument-lights-norm") >1.0){
	setprop("/systems/electrical/outputs/instrument-lights-norm", 1.0)};


var GL_DIMMER = (getprop("/systems/electrical/outputs/ecrf")) * (getprop("controls/lighting/glareshield-lights-norm"));
if ( bus_volts > 22 ) {
	if (getprop ("/controls/lighting/glareshield-lights-norm") >0.05){
	setprop("/systems/electrical/outputs/glareshield-lights",GL_DIMMER);
	setprop("/systems/electrical/outputs/glareshield-lights-norm",GL_DIMMER/28);
	}
	}else{
	setprop("/systems/electrical/outputs/glareshield-lights",0);
	setprop("/systems/electrical/outputs/glareshield-lights-norm",0);
	}
	if (getprop("/systems/electrical/outputs/glareshield-lights-norm") >1.0){
	setprop("/systems/electrical/outputs/glareshield-lights-norm", 1.0)};

	
var PL_DIMMER = (getprop("/systems/electrical/outputs/ecrf")) * (getprop("controls/lighting/pedestal-lights-norm"));
if ( bus_volts > 22 ) {
	if (getprop ("/controls/lighting/pedestal-lights-norm") >0.05){
	setprop("/systems/electrical/outputs/pedestal-lights",PL_DIMMER);
	setprop("/systems/electrical/outputs/pedestal-lights-norm",PL_DIMMER/28);
	}
	}else{
	setprop("/systems/electrical/outputs/pedestal-lights",0);
	setprop("/systems/electrical/outputs/pedestal-lights-norm",0);
	}

	if (getprop("/systems/electrical/outputs/glareshield-lights-norm") >1.0){
	setprop("/systems/electrical/outputs/glareshield-lights-norm", 1.0)};

	

var RL_DIMMER = (getprop("/systems/electrical/outputs/ecrf")) * (getprop("controls/lighting/radio-lights-norm"));
if ( bus_volts > 22 ) {
	if (getprop ("/controls/lighting/radio-lights-norm") >0.05){
	setprop("/systems/electrical/outputs/radio-lights",RL_DIMMER);
	setprop("/systems/electrical/outputs/radio-lights-norm",RL_DIMMER/24);
	}
	}else{
	setprop("/systems/electrical/outputs/radio-lights",0);
	setprop("/systems/electrical/outputs/radio-lights-norm",0);
	}
	if (getprop("/systems/electrical/outputs/radio-lights-norm") >1.0){
	setprop("/systems/electrical/outputs/radio-lights-norm", 1.0)};

    

    # return cumulative load
    return load;
}


avionics_bus_1 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    # we are fed from the electrical bus 1
    var master_av = getprop("/controls/switches/AVMBus1");
    if ( master_av ) {
        bus_volts = ebus1_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
    }

    load += bus_volts / 20.0;

    # Turn Coordinator Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
    }else{
    setprop("/systems/electrical/outputs/turn-coordinator",0);    
    }

    # Avionics Fan Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/avionics-fan", bus_volts);
    }else{
    setprop("/systems/electrical/outputs/avionics-fan", 0);
    }
    
    # GPS Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/gps", bus_volts);
     }else{ 
    setprop("/systems/electrical/outputs/gps", 0);
     }
     
    # HSI Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/hsi", bus_volts);
     }else{ 
    setprop("/systems/electrical/outputs/hsi", 0);
     }
  
    # NavCom 1 Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/nav[0]", bus_volts);
     }else{   
    setprop("/systems/electrical/outputs/nav[0]", 0);
     } 
 
     # DME Power
    if ( bus_volts > 22 ) {
     if (getprop("/controls/switches/kn-62a") > 0) {
         setprop("/systems/electrical/outputs/dme", bus_volts);
        load += bus_volts / 28;
    } 
    }else {
        setprop("/systems/electrical/outputs/dme", 0.0);
    }
  
    # Audio Panel 1 Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);
 #setprop("/instrumentation/audio-panel[0]/serviceable", true);
    #setprop("/instrumentation/marker-beacon[0]/serviceable", true);
     }else{   
    setprop("/systems/electrical/outputs/audio-panel[0]", 0);
 #setprop("/instrumentation/audio-panel[0]/serviceable",0);
   # setprop("/instrumentation/marker-beacon[0]/serviceable", 0);
    }

    # Com 1 Power
    if ( bus_volts > 22 ) {
    setprop("systems/electrical/outputs/comm[0]", bus_volts);
     }else{  
    setprop("systems/electrical/outputs/comm[0]", 0);
}
     
    # return cumulative load
    return load;
}


avionics_bus_2 = func() {
    var master_av = getprop("/controls/switches/AVMBus2");
    # we are fed from the electrical bus 2
    var bus_volts = 0.0;
    if ( master_av ) {
        bus_volts = ebus2_volts;
        bus_volts = sprintf("%.2f", bus_volts);  # reformat to x.yy format
    }
    
    var load = bus_volts / 20.0;

    # NavCom 2 Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/nav[1]", bus_volts);
     }else{  
    setprop("/systems/electrical/outputs/nav[1]", 0);
     }

    # Audio Panel 2 Power
if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);
# setprop("/instrumentation/audio-panel[0]/serviceable, true");
   # setprop("/instrumentation/marker-beacon[0]/serviceable, true");
     }else{ 
    setprop("/systems/electrical/outputs/audio-panel[0]", 0);
 #setprop("/instrumentation/audio-panel[0]/serviceable, 0");
   # setprop("/instrumentation/marker-beacon[0]/serviceable, 0");
}
     
     
    # Com 2 Power
    if ( bus_volts > 22 ) {
    setprop("systems/electrical/outputs/comm[1]", bus_volts);
     }else{ 
    setprop("systems/electrical/outputs/comm[1]", 0);
     }

     # Transponder
    if ( bus_volts > 22 ) {
     if (getprop("/controls/switches/kt-76c") > 0) {
         setprop("/systems/electrical/outputs/kt-76c", bus_volts);
        load += bus_volts / 28;
    } 
    }else {
        setprop("/systems/electrical/outputs/kt-76c", 0.0);
    }

    # Autopilot Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/autopilot", bus_volts);
     }else{ 
    setprop("/systems/electrical/outputs/autopilot", 0);
     }

    # ADF Power
    if ( bus_volts > 22 ) {
    setprop("/systems/electrical/outputs/adf", bus_volts);
     }else{ 
    setprop("/systems/electrical/outputs/adf", 0);
     }

    # return cumulative load
    return load;
}


# Setup a timer based call to initialized the electrical system as
# soon as possible.
setlistener("/sim/signals/fdm-initialized", func {
    init_electrical();
});
