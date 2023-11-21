####################################
# Dual control setup for the c182s
# This needs MP protocol v2. v1 will truncate your packets. The nasal code below will activate V2 automatically if needed.
#
# GPL v2+ license
# (c) 2020 B. Hallinger; loosely based on the ZLT-NT implementation of Anders Gidenstam 2015
####################################


var DCT = dual_control_tools;

# Pilot/copilot aircraft identifiers. Used by dual_control to detect matching clients
var pilot_type   = "Aircraft/c182s/Models/c182s.xml";
var copilot_type = "Aircraft/c182s/Models/c182s-copilot.xml";

var rmt_pilot_cs = props.globals.initNode("/sim/remote/pilot-callsign", "", "STRING");
var pilot_switches_breakers_mpp  = "sim/multiplay/generic/int[17]";  # basic switches and breakers state
var pilot_avionics_mpp           = "sim/multiplay/generic/int[18]";  # basic avionics state
var pilot_serviceable_mpp        = "sim/multiplay/generic/int[19]";  # serviceable state / failures
var pilot_aileron                = "sim/multiplay/generic/float[17]";
var pilot_elevator               = "sim/multiplay/generic/float[18]";
var pilot_airspeed               = "sim/multiplay/generic/float[19]";
var pilot_inst_ai_pitch          = "sim/multiplay/generic/float[20]";
var pilot_inst_ai_roll           = "sim/multiplay/generic/float[21]";
var pilot_inst_altft             = "sim/multiplay/generic/float[22]";
var pilot_inst_egt               = "sim/multiplay/generic/float[23]";
var pilot_inst_cht               = "sim/multiplay/generic/float[24]";
var pilot_inst_vsi               = "sim/multiplay/generic/float[25]";
var pilot_inst_hsi               = "sim/multiplay/generic/float[26]";
var pilot_inst_turn_1            = "sim/multiplay/generic/float[27]";
var pilot_inst_turn_2            = "sim/multiplay/generic/float[28]";
var pilot_inst_manpres           = "sim/multiplay/generic/float[29]";
var pilot_inst_fuelflow          = "sim/multiplay/generic/float[34]";
var pilot_inst_vor1_cdi          = "sim/multiplay/generic/float[35]";
var pilot_inst_vor1_gs           = "sim/multiplay/generic/float[36]";
var pilot_inst_vor2_cdi          = "sim/multiplay/generic/float[37]";
var pilot_inst_vor2_gs           = "sim/multiplay/generic/float[38]";



var pilot_TDM1_mpp       = "sim/multiplay/generic/string[1]"; # flight controls input
var pilot_TDM2_mpp       = "sim/multiplay/generic/string[2]"; # levers
var pilot_TDM3_mpp       = "sim/multiplay/generic/string[3]"; # securings
var pilot_TDM4_mpp       = "sim/multiplay/generic/string[4]"; # elec system parts
var pilot_TDM5_mpp       = "sim/multiplay/generic/string[5]"; # slow instrumentation/avionics stuff
var pilot_TDM6_mpp       = "sim/multiplay/generic/string[6]"; # slow instrumentation/avionics stuff


# The following nodes must be inited here because otherwise they may still be nil.
# This is especially true for some properties that are saved from the plane session,
# but set during the session firstly and thus not present on the very first start of it.
props.globals.initNode("environment/aircraft-effects/cabin-air-set", 0.0, "DOUBLE");
props.globals.initNode("environment/aircraft-effects/cabin-heat-set", 0.0, "DOUBLE");
props.globals.initNode("environment/aircraft-effects/defrost-set", 0.0, "DOUBLE");
props.globals.initNode("controls/SunVisor[0]/position-deg", 0.0, "DOUBLE");
props.globals.initNode("controls/SunVisor[1]/position-deg", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/instrument-lights-norm", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/glareshield-lights-norm", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/pedestal-lights-norm", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/radio-lights-norm", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/dome-light-l", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/dome-light-r", 0.0, "DOUBLE");
props.globals.initNode("systems/electrical/outputs/dome-exterior-light", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/airspeed-indicator/tas-face-rotation", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/attitude-indicator/horizon-offset-deg", 0.0, "DOUBLE");
props.globals.initNode("engines/engine[0]/egt-bug-norm", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/nav[0]/filtered-cdiNAV0-deflection", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/nav[0]/filtered-gsNAV0-deflection", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/nav[1]/filtered-cdiNAV1-deflection", 0.0, "DOUBLE");
props.globals.initNode("instrumentation/nav[1]/filtered-gsNAV1-deflection", 0.0, "DOUBLE");




##########################
# Pilot MP property mappings and specific copilot connect/disconnect actions.
##########################
var l_dual_control = "fdm/jsbsim/fcs/dual-control/enabled";


# Used by dual_control to set up the mappings for the pilot.
var pilot_connect_copilot = func (copilot) {
    # Make sure dual-control is activated in the FDM FCS.
    settimer(func { setprop(l_dual_control, 1); }, 1);

    setprop("payload/weight[1]/weight-lb", 150); # add copilot to pax
    
    # needs at least V2 multiplay packets
    if (getprop("sim/multiplay/protocol-version") < 2) setprop("sim/multiplay/protocol-version", 2);
    
    # Add dynamic MP transmissions that must occur in realtime
    # (see also c182s.xml model definition where the other(=receiving) side is defined).
    # We want to do it this way to save bandwith on ordinary MP models.
    props.globals.getNode(pilot_aileron, 1).
            alias(props.globals.getNode("controls/flight/aileron"));
    props.globals.getNode(pilot_elevator, 1).
        alias(props.globals.getNode("controls/flight/elevator"));
    props.globals.getNode(pilot_airspeed, 1).
        alias(props.globals.getNode("fdm/jsbsim/velocities/vias-kts"));
    props.globals.getNode(pilot_inst_ai_pitch, 1).
        alias(props.globals.getNode("instrumentation/attitude-indicator/indicated-pitch-deg"));
    props.globals.getNode(pilot_inst_ai_roll, 1).
        alias(props.globals.getNode("instrumentation/attitude-indicator/indicated-roll-deg"));
    props.globals.getNode(pilot_inst_altft, 1).
        alias(props.globals.getNode("instrumentation/altimeter/indicated-altitude-ft"));
    props.globals.getNode(pilot_inst_egt, 1).
        alias(props.globals.getNode("engines/engine/indicated-egt-degf"));
    props.globals.getNode(pilot_inst_cht, 1).
        alias(props.globals.getNode("engines/engine/indicated-cht-degf"));
    props.globals.getNode(pilot_inst_vsi, 1).
        alias(props.globals.getNode("instrumentation/vertical-speed-indicator/indicated-speed-fpm-final"));
    props.globals.getNode(pilot_inst_hsi, 1).
        alias(props.globals.getNode("instrumentation/heading-indicator/indicated-heading-deg"));
    props.globals.getNode(pilot_inst_turn_1, 1).
        alias(props.globals.getNode("instrumentation/turn-indicator/indicated-turn-rate"));
    props.globals.getNode(pilot_inst_turn_2, 1).
        alias(props.globals.getNode("instrumentation/slip-skid-ball/indicated-slip-skid"));
    props.globals.getNode(pilot_inst_manpres, 1).
        alias(props.globals.getNode("engines/engine/mp-inhg"));
    props.globals.getNode(pilot_inst_fuelflow, 1).
        alias(props.globals.getNode("engines/engine/indicated-manfold-fuel-flow-gph"));
    props.globals.getNode(pilot_inst_vor1_cdi, 1).
        alias(props.globals.getNode("instrumentation/nav[0]/filtered-cdiNAV0-deflection"));
    props.globals.getNode(pilot_inst_vor1_gs, 1).
        alias(props.globals.getNode("instrumentation/nav[0]/filtered-gsNAV0-deflection"));
    props.globals.getNode(pilot_inst_vor2_cdi, 1).
        alias(props.globals.getNode("instrumentation/nav[1]/filtered-cdiNAV1-deflection"));
    props.globals.getNode(pilot_inst_vor2_gs, 1).
        alias(props.globals.getNode("instrumentation/nav[1]/filtered-gsNAV1-deflection"));


    return [

        ##################################################################
        # Process received properties from the copilot.


        # Copilot main flight control
#        DCT.Translator.new(
#            copilot.getNode(copilot_elevator_mpp),
#            props.globals.getNode("/fdm/jsbsim/fcs/copilot/pitch-cmd-norm")
#        ),
#        DCT.Translator.new(
#            copilot.getNode(copilot_rudder_mpp),
#            props.globals.getNode("/fdm/jsbsim/fcs/copilot/yaw-cmd-norm")
#        ),

#        # Copilot elevator trim control
#        DCT.DeltaAdder.new(
#            copilot.getNode(copilot_elevator_trim_mpp),
#            props.globals.getNode(l_elevator_trim_cmd)
#        ),

#        # Copilot engine control inputs
#        # Thrust sharing
#        DCT.MostRecentSelector.new(
#            props.globals.getNode(l_pilot_thrust_cmd),
#            copilot.getNode(copilot_thrust_cmd_mpp),
#            props.globals.getNode(l_shared_thrust_cmd),
#            0.02
#        ),

#        # Mixture sharing
#        DCT.MostRecentSelector.new(
#            props.globals.getNode(l_pilot_mixture_cmd),
#            copilot.getNode(copilot_mixture_cmd_mpp),
#            props.globals.getNode(l_shared_mixture_cmd),
#            0.02
#        ),





    ##############################################################
    # Process properties to send to the copilot

        # Encoding basic switches and breakers
        DCT.SwitchEncoder.new(
          [
            props.globals.getNode("controls/engines/engine/master-bat"),
            props.globals.getNode("controls/engines/engine/master-alt"),
            props.globals.getNode("controls/engines/engine/fuel-pump"),
            props.globals.getNode("controls/lighting/beacon"),
            props.globals.getNode("controls/lighting/strobe"),
            props.globals.getNode("controls/lighting/landing-lights"),
            props.globals.getNode("controls/lighting/taxi-light"),
            props.globals.getNode("controls/lighting/nav-lights"),
            props.globals.getNode("controls/anti-ice/pitot-heat"),
            props.globals.getNode("controls/switches/AVMBus1"),
            props.globals.getNode("controls/switches/AVMBus2"),
            props.globals.getNode("controls/lighting/dome-light-l"),
            props.globals.getNode("controls/lighting/dome-light-r"),
            props.globals.getNode("controls/lighting/dome-exterior-light"),
            props.globals.getNode("systems/static-selected-source"),
            props.globals.getNode("controls/circuit-breakers/Flap"),
            props.globals.getNode("controls/circuit-breakers/Inst"),
            props.globals.getNode("controls/circuit-breakers/AVNBus1"),
            props.globals.getNode("controls/circuit-breakers/AVNBus2"),
            props.globals.getNode("controls/circuit-breakers/TurnCoord"),
            props.globals.getNode("controls/circuit-breakers/InstLts"),
            props.globals.getNode("controls/circuit-breakers/AltFLD"),
            props.globals.getNode("controls/circuit-breakers/Warn"),
            props.globals.getNode("controls/circuit-breakers/AvionicsFan"),
            props.globals.getNode("controls/circuit-breakers/GPS"),
            props.globals.getNode("controls/circuit-breakers/NavCom1"),
            props.globals.getNode("controls/circuit-breakers/NavCom2"),
            props.globals.getNode("controls/circuit-breakers/Transponder"),
            props.globals.getNode("controls/circuit-breakers/ADF"),
            props.globals.getNode("controls/circuit-breakers/AutoPilot")
          ] , props.globals.getNode(pilot_switches_breakers_mpp, 1)
        ),

       # Encoding Avionics state
       DCT.SwitchEncoder.new(
        [
            props.globals.getNode("instrumentation/nav[0]/to-flag"),
            props.globals.getNode("instrumentation/nav[0]/from-flag"),
            props.globals.getNode("instrumentation/nav[0]/in-range"),
            props.globals.getNode("instrumentation/nav[0]/gs-in-range"),
            props.globals.getNode("instrumentation/nav[1]/to-flag"),
            props.globals.getNode("instrumentation/nav[1]/from-flag"),
            props.globals.getNode("instrumentation/nav[1]/in-range"),
            props.globals.getNode("instrumentation/nav[1]/gs-in-range"),
        ],props.globals.getNode(pilot_avionics_mpp, 1)
       ),

       # Encoding serviceable state/failures
       DCT.SwitchEncoder.new(
        [
            props.globals.getNode("instrumentation/magnetic-compass/serviceable"),
            # .. todo: more needed
        ],props.globals.getNode(pilot_serviceable_mpp, 1)
       ),


        # Set up TDM transmission of slow state properties.
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("controls/engines/engine[0]/throttle"),
                props.globals.getNode("controls/engines/engine[0]/mixture"),
                props.globals.getNode("controls/engines/engine[0]/propeller-pitch"),
                props.globals.getNode("controls/flight/elevator-trim"),
                props.globals.getNode("controls/flight/rudder-trim"),
                props.globals.getNode("controls/flight/rudder"),
                props.globals.getNode("controls/gear/brake-left"),
                props.globals.getNode("controls/gear/brake-right"),
            ],
            props.globals.getNode(pilot_TDM1_mpp, 1)
        ),
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("controls/switches/magnetos"),
                props.globals.getNode("controls/switches/starter"),
                props.globals.getNode("controls/engines/engine/cowl-flaps-norm"),
                props.globals.getNode("controls/switches/fuel_tank_selector"),
                props.globals.getNode("sim/model/c182s/cockpit/flaps-lever"),
                props.globals.getNode("environment/aircraft-effects/cabin-air-set"),
                props.globals.getNode("environment/aircraft-effects/cabin-heat-set"),
                props.globals.getNode("environment/aircraft-effects/defrost-set"),
                props.globals.getNode("controls/SunVisor[0]/position-deg"),
                props.globals.getNode("controls/SunVisor[1]/position-deg"),
                props.globals.getNode("sim/model/c182s/cockpit/brake-lever"),
            ],
            props.globals.getNode(pilot_TDM2_mpp, 1)
        ),
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("sim/model/c182s/securing/pitot-cover-visible"),
                props.globals.getNode("engines/engine/winter-kit-installed"),
                props.globals.getNode("sim/model/c182s/securing/tiedownL-visible"),
                props.globals.getNode("sim/model/c182s/securing/tiedownR-visible"),
                props.globals.getNode("sim/model/c182s/securing/tiedownT-visible"),
                #not supported, nasal driven:props.globals.getNode("sim/chocks001/enable"),
                #not supported, nasal driven:props.globals.getNode("sim/chocks002/enable"),
                #not supported, nasal driven:props.globals.getNode("sim/chocks003/enable"),
            ],
            props.globals.getNode(pilot_TDM3_mpp, 1)
        ),
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("systems/electrical/outputs/instrument-lights-norm"),
                props.globals.getNode("systems/electrical/outputs/glareshield-lights-norm"),
                props.globals.getNode("systems/electrical/outputs/pedestal-lights-norm"),
                props.globals.getNode("systems/electrical/outputs/radio-lights-norm"),
                props.globals.getNode("systems/electrical/outputs/dome-light-l"),
                props.globals.getNode("systems/electrical/outputs/dome-light-r"),
                props.globals.getNode("systems/electrical/outputs/dome-exterior-light"),
            ],
            props.globals.getNode(pilot_TDM4_mpp, 1)
        ),
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("instrumentation/airspeed-indicator/tas-face-rotation"),
                props.globals.getNode("sim/time/hobbs/engine"),
                props.globals.getNode("instrumentation/attitude-indicator/horizon-offset-deg"),
                props.globals.getNode("instrumentation/attitude-indicator/caged-flag"),
                props.globals.getNode("instrumentation/altimeter/setting-inhg"),
                props.globals.getNode("engines/engine[0]/egt-bug-norm"),
                props.globals.getNode("consumables/fuel/tank[0]/indicated-level-gal_us"),
                props.globals.getNode("consumables/fuel/tank[1]/indicated-level-gal_us"),
                props.globals.getNode("instrumentation/adf[0]/rotation-deg"),
                props.globals.getNode("instrumentation/adf[0]/indicated-bearing-deg"),
            ],
            props.globals.getNode(pilot_TDM5_mpp, 1)
        ),
        DCT.TDMEncoder.new(
            [
                props.globals.getNode("autopilot/settings/heading-bug-deg"),
                props.globals.getNode("instrumentation/heading-indicator/offset-deg"),
                props.globals.getNode("engines/engine/indicated-oil-final-temperature-degf"),
                props.globals.getNode("engines/engine/indicated-oil-pressure-psi"),
                props.globals.getNode("systems/vacuum/suction-inhg"),
                props.globals.getNode("systems/electrical/amps"),
                props.globals.getNode("instrumentation/nav[0]/radials/selected-deg"),
                props.globals.getNode("instrumentation/nav[1]/radials/selected-deg"),
            ],
            props.globals.getNode(pilot_TDM6_mpp, 1)
        ),

    ];
};

var pilot_disconnect_copilot = func {
    # Reset copilot controls. Slightly dangerous.
    setprop("/fdm/jsbsim/fcs/copilot/pitch-cmd-norm", 0.0);
    setprop("/fdm/jsbsim/fcs/copilot/yaw-cmd-norm", 0.0);
    setprop(l_dual_control, 0);

    setprop("payload/weight[1]/weight-lb", 0); # remove copilot from pax

    # remove additional MP properties from sending
    setprop("/sim/remote/pilot-callsign", "");
    props.globals.getNode(pilot_aileron, 1).unalias();
    props.globals.getNode(pilot_elevator, 1).unalias();
    props.globals.getNode(pilot_airspeed, 1).unalias();
    props.globals.getNode(pilot_inst_ai_pitch, 1).unalias();
    props.globals.getNode(pilot_inst_ai_roll, 1).unalias();
    props.globals.getNode(pilot_inst_altft, 1).unalias();
    props.globals.getNode(pilot_inst_egt, 1).unalias();
    props.globals.getNode(pilot_inst_cht, 1).unalias();
    props.globals.getNode(pilot_inst_vsi, 1).unalias();
    props.globals.getNode(pilot_inst_hsi, 1).unalias();
    props.globals.getNode(pilot_inst_turn_1, 1).unalias();
    props.globals.getNode(pilot_inst_turn_2, 1).unalias();
    props.globals.getNode(pilot_inst_manpres, 1).unalias();
    props.globals.getNode(pilot_inst_fuelflow, 1).unalias();
    props.globals.getNode(pilot_inst_vor1_cdi, 1).unalias();
    props.globals.getNode(pilot_inst_vor1_gs, 1).unalias();
    props.globals.getNode(pilot_inst_vor2_cdi, 1).unalias();
    props.globals.getNode(pilot_inst_vor2_gs, 1).unalias();
};




# Used by dual_control to set up the mappings for the copilot.
var copilot_connect_pilot = func (pilot) {
    
    # needs at least V2 multiplay packets
    if (getprop("sim/multiplay/protocol-version") < 2) setprop("sim/multiplay/protocol-version", 2);
    
    # Fake/alias local properties
    pilot.getNode("instrumentation/magnetic-compass/indicated-heading-deg", 1).
        alias(props.globals.getNode("instrumentation/magnetic-compass/indicated-heading-deg"));
    pilot.getNode("engines/engine/thruster/rpm", 1).
        alias(pilot.getNode("engines/engine/rpm"));
    
    
    return [
    
        ##################################################################
        # Process received properties from the pilot.
        
        # Decode switches and breakers state
        DCT.SwitchDecoder.new( pilot.getNode(pilot_switches_breakers_mpp),
          [
            func (b) {  setprop(pilot.getPath()~"/controls/engines/engine/master-bat", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/engines/engine/master-alt", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/engines/engine/fuel-pump", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/beacon", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/strobe", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/landing-lights", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/taxi-light", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/nav-lights", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/anti-ice/pitot-heat", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/switches/AVMBus1", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/switches/AVMBus2", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/dome-light-l", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/dome-light-r", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/lighting/dome-exterior-light", b)  },
            func (b) {  setprop(pilot.getPath()~"/systems/static-selected-source-norm", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/Flap", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/Inst", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/AVNBus1", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/AVNBus2", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/TurnCoord", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/InstLts", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/AltFLD", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/Warn", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/AvionicsFan", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/GPS", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/NavCom1", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/NavCom2", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/Transponder", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/ADF", b)  },
            func (b) {  setprop(pilot.getPath()~"/controls/circuit-breakers/AutoPilot", b)  },
          ]),


        # Decode serviceable state / failures
        DCT.SwitchDecoder.new( pilot.getNode(pilot_avionics_mpp),
          [
            func (b) {  pilot.getNode("instrumentation/nav[0]/from-flag").setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[0]/to-flag").setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[0]/in-range").setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[0]/gs-in-range").setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[1]/from-flag", 1).setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[1]/to-flag", 1).setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[1]/in-range", 1).setBoolValue(b)  },
            func (b) {  pilot.getNode("instrumentation/nav[1]/gs-in-range", 1).setBoolValue(b)  },
          ]),


        # Decode serviceable state / failures
        DCT.SwitchDecoder.new( pilot.getNode(pilot_serviceable_mpp),
          [
            func (b) {  props.globals.getNode("instrumentation/magnetic-compass/serviceable").setBoolValue(b)  },  # note: local instrument
            #func (b) {  pilot.getNode("bla/serviceable").setBoolValue(b)  },
          ]),


        # Set up TDM reception of slow state properties.
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM1_mpp),
          [
            func (v) { pilot.getNode("controls/engines/engine[0]/throttle",1).setValue(v)  },
            func (v) { pilot.getNode("controls/engines/engine[0]/mixture",1).setValue(v)  },
            func (v) { pilot.getNode("controls/engines/engine[0]/propeller-pitch",1).setValue(v)  },
            func (v) { pilot.getNode("controls/flight/elevator-trim",1).setValue(v)  },
            func (v) { pilot.getNode("controls/flight/rudder-trim",1).setValue(v)  },
            func (v) { pilot.getNode("controls/flight/rudder",1).setValue(v)  },
            func (v) { pilot.getNode("controls/gear/brake-left",1).setValue(v)  },
            func (v) { pilot.getNode("controls/gear/brake-right",1).setValue(v)  },
          ]),
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM2_mpp),
          [
            func (v) { pilot.getNode("controls/switches/magnetos",1).setValue(v)  },
            func (v) { pilot.getNode("controls/switches/starter",1).setValue(v)  },
            func (v) { pilot.getNode("controls/engines/engine/cowl-flaps-norm",1).setValue(v)  },
            func (v) { pilot.getNode("controls/switches/fuel_tank_selector",1).setValue(v)  },
            func (v) { pilot.getNode("sim/model/c182s/cockpit/flaps-lever",1).setValue(v)  },
            func (v) { pilot.getNode("environment/aircraft-effects/cabin-air-set",1).setValue(v)  },
            func (v) { pilot.getNode("environment/aircraft-effects/cabin-heat-set",1).setValue(v)  },
            func (v) { pilot.getNode("environment/aircraft-effects/defrost-set",1).setValue(v)  },
            func (v) { pilot.getNode("controls/SunVisor[0]/position-deg",1).setValue(v)  },
            func (v) { pilot.getNode("controls/SunVisor[1]/position-deg",1).setValue(v)  },
            func (v) { pilot.getNode("sim/model/c182s/cockpit/brake-lever",1).setValue(v)  },
          ]),
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM3_mpp),
          [
            func (v) { pilot.getNode("sim/model/c182s/securing/pitot-cover-visible",1).setValue(v)  },
            func (v) { pilot.getNode("engines/engine/winter-kit-installed",1).setValue(v)  },
            func (v) { pilot.getNode("sim/model/c182s/securing/tiedownL-visible",1).setValue(v)  },
            func (v) { pilot.getNode("sim/model/c182s/securing/tiedownR-visible",1).setValue(v)  },
            func (v) { pilot.getNode("sim/model/c182s/securing/tiedownT-visible",1).setValue(v)  },
            #not supported, nasal driven: func (v) { pilot.getNode("sim/chocks001/enable",1).setValue(v)  },
            #not supported, nasal driven: func (v) { pilot.getNode("sim/chocks002/enable",1).setValue(v)  },
            #not supported, nasal driven: func (v) { pilot.getNode("sim/chocks003/enable",1).setValue(v)  },
          ]),
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM4_mpp),
          [
            func (v) { pilot.getNode("systems/electrical/outputs/instrument-lights-norm",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/glareshield-lights-norm",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/pedestal-lights-norm",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/radio-lights-norm",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/dome-light-l",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/dome-light-r",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/outputs/dome-exterior-light",1).setValue(v)  },
          ]),
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM5_mpp),
          [
            func (v) { pilot.getNode("instrumentation/airspeed-indicator/tas-face-rotation",1).setValue(v)  },
            func (v) { pilot.getNode("sim/time/hobbs/engine",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/attitude-indicator/horizon-offset-deg",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/attitude-indicator/caged-flag",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/altimeter/setting-inhg",1).setValue(v)  },
            func (v) { pilot.getNode("engines/engine[0]/egt-bug-norm",1).setValue(v)  },
            func (v) { pilot.getNode("consumables/fuel/tank[0]/indicated-level-gal_us",1).setValue(v)  },
            func (v) { pilot.getNode("consumables/fuel/tank[1]/indicated-level-gal_us",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/adf[0]/rotation-deg",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/adf[0]/indicated-bearing-deg",1).setValue(v)  },
          ]),
        DCT.TDMDecoder.new( pilot.getNode(pilot_TDM6_mpp),
          [
            func (v) { pilot.getNode("autopilot/settings/heading-bug-deg",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/heading-indicator/offset-deg",1).setValue(v)  },
            func (v) { pilot.getNode("engines/engine/indicated-oil-final-temperature-degf",1).setValue(v)  },
            func (v) { pilot.getNode("engines/engine/indicated-oil-pressure-psi",1).setValue(v)  },
            func (v) { pilot.getNode("systems/vacuum/suction-inhg",1).setValue(v)  },
            func (v) { pilot.getNode("systems/electrical/amps",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/nav[0]/radials/selected-deg",1).setValue(v)  },
            func (v) { pilot.getNode("instrumentation/nav[1]/radials/selected-deg",1).setValue(v)  },
          ]),
        


        ##############################################################
        # Process properties to send to the pilot

    ];
};

var copilot_disconnect_pilot = func {
  setprop("/sim/remote/pilot-callsign", "");
};


print("Dual control ... C182s specific dual-control module initialized");
