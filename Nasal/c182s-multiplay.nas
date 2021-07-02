####################################
# Nasal multiplayer parts
#
# This is an extension to the multiplayer protocol to transmit "slow properties".
# Note: Most properties are transmitted the "normal" way via direct MP-Properties/packets.
#
# That here is for not so important/cosmetic stuff that doesn't fit in normal properties anymore.
# The remote models also register functions to decode these packed properties.
#
# (c) 2021 B. Hallinger
####################################


var DCT = dual_control_tools;

var c182_mp_slowprop_TDM1 = DCT.TDMEncoder.new(
    [
        props.globals.getNode("gear/gear[0]/rollspeed-ms"),
        props.globals.getNode("gear/gear[1]/rollspeed-ms"),
        props.globals.getNode("gear/gear[2]/rollspeed-ms"),
        props.globals.getNode("gear/gear/steering-norm"),
        props.globals.getNode("fdm/jsbsim/ice/graphic"),
    ],
    props.globals.getNode("sim/multiplay/generic/string[7]", 1)
);


c182_mp_slowprop_TDM1_updater = maketimer(0.25, func{
    #print("C182 MP extended slow properties TDM1 encoder update()");
    c182_mp_slowprop_TDM1.update();
});
setlistener("sim/signals/fdm-initialized", func {
    c182_mp_slowprop_TDM1_updater.start();
    print("C182 MP extended slow properties initialized");
});
