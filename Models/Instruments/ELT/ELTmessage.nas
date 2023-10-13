#Basic ELT (Emergency Locator Transmitter)
#Authors: Pavel Cueto, with A LOT of collaboration from Thorsten and AndersG

#Designed to work with the "ArtexELT" files provided in the instrument folder.
#Be sure to link this Nasal in your -set file, typing:
#<nasal>
#	<ELT>
#		<file>YOUR/INSTRUMENT/FOLDER/ROUTE/HERE/ELTmessage.nas</file>
#	</ELT>
#</nasal>
#
# Logic modified by B. Hallinger for C182 12/2021

#Aircraft ID definition
var aircraft = getprop("sim/description");
var callsign = getprop("sim/multiplay/callsign");
var aircraft_id = aircraft ~ ", " ~ callsign;

var crash_detected = 0;

# Transmit message
var transmit = maketimer(60, func(){
    var ground    = getprop("position/altitude-agl-ft");
    var lat       = getprop("/position/latitude-string");
    var lon       = getprop("/position/longitude-string");
    var repairing = getprop("/fdm/jsbsim/damage/repairing");
    
    if (getprop("instrumentation/elt/armed") and crash_detected and ground < 25 and !repairing) {
        var help_string = "ELT AutoMessage: " ~ aircraft_id ~ ", CRASHED AT " ~lat~" LAT "~lon~" LON, REQUESTING SAR SERVICE";
        setprop("/sim/multiplay/chat", help_string);
        print(help_string);
        transmit.restart(60);
        setprop("instrumentation/elt/transmitting", 1);

    } elsif (getprop("instrumentation/elt/on") and !repairing) {
        var help_string = "ELT Message: " ~ aircraft_id ~ ", DECLARING EMERGENCY AT " ~lat~" LAT, "~lon~" LON";
        setprop("/sim/multiplay/chat", help_string);
        print(help_string);
        transmit.restart(60);
        setprop("instrumentation/elt/transmitting", 1);

    } else {
        crash_detected = 0;
        transmit.stop();
        setprop("instrumentation/elt/transmitting", 0);
    }
});
transmit.simulatedTime = 1;

# INIT
setlistener("sim/signals/fdm-initialized", func {
    #Print an emergency auto-message when aircraft crashes
    setlistener("engines/engine/crashed", func(){
        if (getprop("engines/engine/crashed")) crash_detected = 1;
        transmit.restart(0.1)
    }, 0, 0);

    #Print an manual emergency message when pilot turns on the "ON" button
    # Note: This is also used for testing and should only be activated in the first 5 minutes of each hour
    # and not for longer than three seconds.
    #setlistener("instrumentation/elt/on", func(){transmit.restart(0.1)}, 0, 0);
    setlistener("instrumentation/elt/switchpos", func(){transmit.restart(0.1)}, 0, 0);

    print("Emergency Locator Transmitter (ELT) initialized");
});
