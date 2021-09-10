# MariuszXC - taken almost verbatim from Cessna 172p

# Copyright (C) 2017  onox
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

var dt = 0.5;
var fast_dt = 0.3;

var views = props.globals.getNode("sim").getChildren("view");


# mode == 0 - restore default view
# mode == 1 - restore saved view 
#
var reset_view = func (mode) {

	print("reset-view mode: " ~ mode);

    var index = getprop("sim/current-view/view-number");

	var conf_heading_deg = getprop("sim/current-view/config/heading-offset-deg");
	var conf_roll_deg = getprop("sim/current-view/config/roll-offset-deg");

	var curr_heading_deg = getprop("sim/current-view/heading-offset-deg");	
    if (curr_heading_deg > 180.0) conf_heading_deg += 360.0;

	if (mode == 0) {
		debug.dump(views);
		#var pitch_deg = pitch_deg = getprop("sim/current-view/config/pitch-offset-deg");
        #var fov = getprop("sim/current-view/config/default-field-of-view-deg");
        #var x_offset = views[index].getValue("config/x-offset-m");
        #var y_offset = views[index].getValue("config/y-offset-m");
        #var z_offset = views[index].getValue("config/z-offset-m");
	} else {
		debug.dump(views);
		#setprop("sim/current-view/view-number", 0);
        #var pitch_deg = pitch_deg = getprop("sim/current-view/user/pitch-offset-deg");
        #var fov = getprop("sim/current-view/user/default-field-of-view-deg");
        #var x_offset = getprop("sim/current-view/user/x-offset-m");
        #var y_offset = getprop("sim/current-view/user/y-offset-m");
        #var z_offset = getprop("sim/current-view/user/z-offset-m");
	}

	#interpolate("sim/current-view/field-of-view", fov, dt);
	#interpolate("sim/current-view/heading-offset-deg", conf_heading_deg, dt);
	#nterpolate("sim/current-view/pitch-offset-deg", pitch_deg, dt);
	#interpolate("sim/current-view/roll-offset-deg", conf_roll_deg, dt);
	#interpolate("sim/current-view/x-offset-m", x_offset, dt);
	#interpolate("sim/current-view/y-offset-m", y_offset, dt);
	#interpolate("sim/current-view/z-offset-m", z_offset, dt);
};

var update_view = func () {
	#setprop("sim/current-view/user/y-offset-m", getprop("sim/current-view/y-offset-m"));
	#setprop("sim/current-view/user/z-offset-m", getprop("sim/current-view/z-offset-m"));
	#setprop("sim/current-view/user/pitch-offset-deg", getprop("sim/current-view/pitch-offset-deg"));
};
