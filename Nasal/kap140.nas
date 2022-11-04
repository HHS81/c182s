var config = io.read_properties("Models/Instruments/Avionics/kap140/kap140-config.xml");

var kap140_ap   = props.globals.initNode("autopilot/kap140/event/button-ap" ,  0, "BOOL");
var kap140_hdg  = props.globals.initNode("autopilot/kap140/event/button-hdg",  0, "BOOL");
var kap140_nav  = props.globals.initNode("autopilot/kap140/event/button-nav",  0, "BOOL");
var kap140_apr  = props.globals.initNode("autopilot/kap140/event/button-apr",  0, "BOOL");
var kap140_rev  = props.globals.initNode("autopilot/kap140/event/button-rev",  0, "BOOL");
var kap140_alt  = props.globals.initNode("autopilot/kap140/event/button-alt",  0, "BOOL");
var kap140_down = props.globals.initNode("autopilot/kap140/event/button-down", 0, "BOOL");
var kap140_up   = props.globals.initNode("autopilot/kap140/event/button-up",   0, "BOOL");
var kap140_arm  = props.globals.initNode("autopilot/kap140/event/button-arm",  0, "BOOL");
var kap140_baro = props.globals.initNode("autopilot/kap140/event/button-baro", 0, "BOOL");
var kap140_outer= props.globals.initNode("autopilot/kap140/event/knob-outer",  0, "INT");
var kap140_inner= props.globals.initNode("autopilot/kap140/event/knob-inner",  0, "INT");



setlistener(kap140_ap, func(ap) {
    if (ap.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-ap",     getprop("sim/time/elapsed-sec"));
        setprop("autopilot/kap140/panel/state-old",     getprop("autopilot/kap140/panel/state"));
        setprop("autopilot/internal/target-climb-rate", getprop("autopilot/internal/vert-speed-fpm"));
    }
    else
    {
        setprop("autopilot/kap140/panel/button-ap", 0);
    }
},0,0);

setlistener(kap140_hdg, func(hdg) {
    if (hdg.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-hdg", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            if (
                getprop("autopilot/kap140/settings/lateral-mode") < 3 and
                getprop("autopilot/kap140/settings/lateral-arm") < 3
            ) {
                if (getprop("autopilot/kap140/settings/lateral-mode") == 1)
                {
                    setprop("autopilot/kap140/settings/lateral-mode", 2);
                }
                else if (getprop("autopilot/kap140/settings/lateral-mode") == 2)
                {
                    setprop("autopilot/kap140/settings/lateral-mode", 1);
                }
            }
            if (
                getprop("autopilot/kap140/settings/lateral-mode") > 2 and
                getprop("autopilot/kap140/settings/lateral-mode") < 6
            ) {
                if (getprop("autopilot/kap140/settings/from-hdg"))
                {
                    setprop("autopilot/kap140/settings/lateral-mode", 2);
                }
                else
                {
                    setprop("autopilot/kap140/settings/lateral-mode", 1);
                }
            }
            if (getprop("autopilot/kap140/settings/lateral-mode") < 3)
            {
                setprop("autopilot/kap140/settings/from-hdg", 0);
            }
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-hdg", 0);
    }
    setprop("autopilot/kap140/settings/lateral-arm", 0);
    setprop("autopilot/internal/target-roll-deg", 0);
    setprop("autopilot/internal/target-intercept-angle", 0);
    setprop("autopilot/kap140/panel/hdg-timer", 0);
    setprop("autopilot/kap140/panel/nav-timer", 0);
},0,0);

setlistener(kap140_nav, func(nav) {
    if (nav.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-nav", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            var hsi_installed = config.getValue("params/hsi-installed");
            if (getprop("autopilot/kap140/settings/lateral-mode") != 3) {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 3) {
                    setprop("autopilot/kap140/settings/lateral-arm", 0);
                }
                else
                {
                    setprop("autopilot/kap140/settings/lateral-arm", 3);
                }
            }
            if (!getprop(hsi_installed))
            {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 3)
                {
                    if (getprop("autopilot/kap140/settings/lateral-mode") == 2)
                    {
                        setprop("autopilot/kap140/settings/from-hdg", 1);
                    }
                    setprop("autopilot/kap140/panel/hdg-timer", getprop("sim/time/elapsed-sec"));
                }
                else
                {
                    setprop("autopilot/kap140/settings/from-hdg", 0);
                    setprop("autopilot/kap140/panel/hdg-timer", 0);
                }
            }
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-nav", 0);
    }
    setprop("autopilot/kap140/panel/nav-timer", 0);
},0,0);

setlistener(kap140_apr, func(apr) {
    if (apr.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-apr", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            var hsi_installed = config.getValue("params/hsi-installed");
            if (getprop("autopilot/kap140/settings/lateral-mode") != 4) {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 4) {
                    setprop("autopilot/kap140/settings/lateral-arm", 0);
                }
                else
                {
                    setprop("autopilot/kap140/settings/lateral-arm", 4);
                }
            }
            if (!getprop(hsi_installed))
            {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 4)
                {
                    if (getprop("autopilot/kap140/settings/lateral-mode") == 2)
                    {
                        setprop("autopilot/kap140/settings/from-hdg", 1);
                    }
                    setprop("autopilot/kap140/panel/hdg-timer", getprop("sim/time/elapsed-sec"));
                }
                else
                {
                    setprop("autopilot/kap140/settings/from-hdg", 0);
                    setprop("autopilot/kap140/panel/hdg-timer", 0);
                }
            }
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-apr", 0);
    }
    setprop("autopilot/kap140/panel/nav-timer", 0);
},0,0);

setlistener(kap140_rev, func(rev) {
    if (rev.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-rev", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            var hsi_installed = config.getValue("params/hsi-installed");
            if (getprop("autopilot/kap140/settings/lateral-mode") != 5) {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 5) {
                    setprop("autopilot/kap140/settings/lateral-arm", 0);
                }
                else
                {
                    setprop("autopilot/kap140/settings/lateral-arm", 5);
                }
            }
            if (!getprop(hsi_installed))
            {
                if (getprop("autopilot/kap140/settings/lateral-arm") == 5)
                {
                    if (getprop("autopilot/kap140/settings/lateral-mode") == 2)
                    {
                        setprop("autopilot/kap140/settings/from-hdg", 1);
                    }
                    setprop("autopilot/kap140/panel/hdg-timer", getprop("sim/time/elapsed-sec"));
                }
                else
                {
                    setprop("autopilot/kap140/settings/from-hdg", 0);
                    setprop("autopilot/kap140/panel/hdg-timer", 0);
                }
            }
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-rev", 0);
    }
    setprop("autopilot/kap140/panel/nav-timer", 0);
},0,0);

setlistener(kap140_alt, func(alt) {
    if (alt.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-alt", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            var pressure_source = config.getValue("params/pressure-source");
            if (getprop("autopilot/kap140/settings/vertical-mode") == 2) {
                setprop("autopilot/kap140/settings/vertical-mode", 1);
                setprop("autopilot/internal/target-pressure", 0.0);
            }
            else if (getprop("autopilot/kap140/settings/vertical-mode") == 1)
            {
                setprop("autopilot/kap140/settings/vertical-mode", 2);
                setprop("autopilot/internal/target-pressure", getprop(pressure_source));
            }
            setprop("autopilot/kap140/panel/gs-timer", 0);
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-alt", 0);
    }
},0,0);

setlistener(kap140_down, func(down) {
    if (down.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-down", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            if (getprop("autopilot/kap140/settings/vertical-mode") == 1 and
                getprop("autopilot/kap140/panel/fpm-timer") > 0)
            {
                var climb = getprop("autopilot/internal/target-climb-rate") - 100;
                if (climb < -2000) climb = -2000;
                setprop("autopilot/internal/target-climb-rate", climb);
            }
            if (getprop("autopilot/kap140/settings/vertical-mode") == 2)
            {
                var pressure = getprop("autopilot/internal/target-pressure") + .022;
                if (pressure > 35.0) pressure = 35.0;
                setprop("autopilot/internal/target-pressure", pressure);
            }
            setprop("autopilot/kap140/panel/fpm-old", getprop("autopilot/internal/target-climb-rate"));
        }
    }
    else
    {
        if (getprop("autopilot/kap140/panel/state") == 6 and
            getprop("autopilot/kap140/settings/vertical-mode") == 2 and
            getprop("sim/time/elapsed-sec") > getprop("autopilot/kap140/panel/button-down") + 1
            )
        {
            var pressure_source = config.getValue("params/pressure-source");
            setprop("autopilot/internal/target-pressure", getprop(pressure_source));
        }
        setprop("autopilot/kap140/panel/button-down", 0);
    }
},0,0);

setlistener(kap140_up, func(up) {
    if (up.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-up", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            if (getprop("autopilot/kap140/settings/vertical-mode") == 1 and
                getprop("autopilot/kap140/panel/fpm-timer") > 0)
            {
                var climb = getprop("autopilot/internal/target-climb-rate") + 100;
                if (climb > 2000) climb = 2000;
                setprop("autopilot/internal/target-climb-rate", climb);
            }
            if (getprop("autopilot/kap140/settings/vertical-mode") == 2)
            {
                var pressure = getprop("autopilot/internal/target-pressure") - .022;
                if (pressure < 5.0) pressure = 5.0;
                setprop("autopilot/internal/target-pressure", pressure);
            }
            setprop("autopilot/kap140/panel/fpm-old", getprop("autopilot/internal/target-climb-rate"));
        }
    }
    else
    {
        if (getprop("autopilot/kap140/panel/state") == 6 and
            getprop("autopilot/kap140/settings/vertical-mode") == 2 and
            getprop("sim/time/elapsed-sec") > getprop("autopilot/kap140/panel/button-up") + 1
            )
        {
            var pressure_source = config.getValue("params/pressure-source");
            setprop("autopilot/internal/target-pressure", getprop(pressure_source));
        }
        setprop("autopilot/kap140/panel/button-up", 0);
    }
},0,0);

setlistener(kap140_arm, func(arm) {
    if (arm.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-arm", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") == 6) {
            if (getprop("autopilot/kap140/settings/vertical-arm") == 2) {
                setprop("autopilot/kap140/settings/vertical-arm", 0);
            }
            else
            {
                setprop("autopilot/kap140/settings/vertical-arm", 2);
            }
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-arm", 0);
    }
},0,0);

setlistener(kap140_baro, func(baro) {
    if (baro.getBoolValue()) {
        setprop("autopilot/kap140/panel/button-baro", getprop("sim/time/elapsed-sec"));
        if (getprop("autopilot/kap140/panel/state") > 3) {
            setprop("autopilot/kap140/panel/baro-mode-old", getprop("autopilot/kap140/panel/baro-mode"));
        }
    }
    else
    {
        setprop("autopilot/kap140/panel/button-baro", 0);
    }
},0,0);

setlistener(kap140_outer, func(outer) {
    if (outer.getValue()) {
        var baro_tied = config.getValue("params/baro-tied");
        var baro_inhg = config.getValue("params/baro-inhg");
        var baro_hpa  = config.getValue("params/baro-hpa");

        if (getprop("autopilot/kap140/panel/state") > 3 and
            getprop("autopilot/kap140/panel/digit-mode") == 3 and
            !getprop(baro_tied))
        {
            if (getprop("autopilot/kap140/panel/baro-mode") == 0) {
                var baro = getprop(baro_inhg) + outer.getValue() * 0.1;
                if (baro < 26.0) baro = 26.0;
                if (baro > 33.0) baro = 33.0;
                setprop(baro_inhg, baro);
            }
            if (getprop("autopilot/kap140/panel/baro-mode") == 1) {
                var baro = getprop(baro_hpa) + outer.getValue() * 10;
                if (baro < 880) baro = 880;
                if (baro > 1118) baro = 1118;
                setprop(baro_hpa, baro);
            }
            setprop("autopilot/kap140/panel/baro-timer", getprop("sim/time/elapsed-sec"));
        }

        if (getprop("autopilot/kap140/panel/state") == 4) {
            setprop("autopilot/kap140/panel/state", 5);
        }

        if (getprop("autopilot/kap140/panel/state") > 4 and
            getprop("autopilot/kap140/panel/digit-mode") == 1)
        {
            var altitude = getprop("autopilot/internal/target-altitude") + outer.getValue() * 1000;
            if (altitude < -1000) altitude = -1000;
            if (altitude > 35000) altitude = 35000;
            setprop("autopilot/internal/target-altitude", altitude);

            if (getprop("autopilot/kap140/panel/state") > 5) {
                setprop("autopilot/kap140/settings/vertical-arm", 2);
            }
        }

        setprop("autopilot/kap140/panel/knob-outer-pos", getprop("autopilot/kap140/panel/knob-outer-pos") + outer.getValue());
        setprop("autopilot/kap140/event/knob-outer", 0);
    }
},0,0);


setlistener(kap140_inner, func(inner) {
    if (inner.getValue()) {
        var baro_tied = config.getValue("params/baro-tied");
        var baro_inhg = config.getValue("params/baro-inhg");
        var baro_hpa  = config.getValue("params/baro-hpa");

        if (getprop("autopilot/kap140/panel/state") > 3 and
            getprop("autopilot/kap140/panel/digit-mode") == 3 and
            !getprop(baro_tied))
        {
            if (getprop("autopilot/kap140/panel/baro-mode") == 0) {
                var baro = getprop(baro_inhg) + inner.getValue() * 0.01;
                if (baro < 26.0) baro = 26.0;
                if (baro > 33.0) baro = 33.0;
                setprop(baro_inhg, baro);
            }
            if (getprop("autopilot/kap140/panel/baro-mode") == 1) {
                var baro = getprop(baro_hpa) + inner.getValue();
                if (baro < 880) baro = 880;
                if (baro > 1118) baro = 1118;
                setprop(baro_hpa, baro);
            }
            setprop("autopilot/kap140/panel/baro-timer", getprop("sim/time/elapsed-sec"));
        }

        if (getprop("autopilot/kap140/panel/state") == 4) {
            setprop("autopilot/kap140/panel/state", 5);
        }

        if (getprop("autopilot/kap140/panel/state") > 4 and
            getprop("autopilot/kap140/panel/digit-mode") == 1)
        {
            var altitude = getprop("autopilot/internal/target-altitude") + inner.getValue() * 100;
            if (altitude < -1000) altitude = -1000;
            if (altitude > 35000) altitude = 35000;
            setprop("autopilot/internal/target-altitude", altitude);

            if (getprop("autopilot/kap140/panel/state") > 5) {
                setprop("autopilot/kap140/settings/vertical-arm", 2);
            }
        }

        setprop("autopilot/kap140/panel/knob-inner-pos", getprop("autopilot/kap140/panel/knob-inner-pos") + inner.getValue());
        setprop("autopilot/kap140/event/knob-inner", 0);
    }
},0,0);

