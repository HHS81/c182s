####################################
# Nasal multiplayer parachuters
#
# This listens to the parachuter drop property and spawns locally visible jumper models.
# Each model is controlled via a simple timed nasal loop.
#
# (c) 2021 B. Hallinger
####################################

print("C182 multiplayer parachuters initializing");
var mp_parachuterjump_spawn = func(rplayer) {
    #print("DBG: mp-parachuters.nas mp_parachuterjump_spawn("~rplayer.getPath()~") called");
    
    #
    # CONFIG
    #
    var chute_open_ft     = 5000;  # Minimum height AGL where the chute opens
    var freefall_down_fps =  176;  # Downward speed in freefall phase
    var chute_down_fps    =   35;  # Downward speed with chute
    var removeCheck_s     =   50;  # model removal after landing check timer interval
    
    
    #
    # Get spawn position
    #
    var coord = geo.Coord.new();
    coord.set_latlon(
        rplayer.getNode("position/latitude-deg").getValue(),
        rplayer.getNode("position/longitude-deg").getValue(),
        rplayer.getNode("position/altitude-ft").getValue()
    );
    var course = rplayer.getNode("orientation/true-heading-deg").getValue();
    
    # adjust spawn point relative to aircraft
    coord.set_alt(coord.alt() - 5);
    coord.apply_course_distance(course+90, 5.0);
    
    
    #
    # setup ai-model data structures
    #
    var model = props.globals.getNode("models", 1).addChild("model", 0, 1);
    var ai    = props.globals.getNode("ai/models", 1).addChild("ballistic", 0, 1);
    
    var m_latN   = ai.getNode("position/latitude-deg", 1);
    var m_lonN   = ai.getNode("position/longitude-deg", 1);
    var m_altN   = ai.getNode("position/altitude-ft", 1);
    var m_hdgN   = ai.getNode("orientation/true-heading-deg", 1);
    var m_pitchN = ai.getNode("orientation/pitch-deg", 1);
    var m_rollN  = ai.getNode("orientation/roll-deg", 1);
    var chute    = ai.getNode("parachuter-chute-state", 1);
    
    # Procedurally generate a xml animation file for it
    #var filename = getprop("/sim/fg-home") ~ "/Export/c182-parachuter-"~ai.getIndex()~".xml";
    var filename = getprop("/sim/fg-home") ~ "/Export/c182-parachuter-dynamic-animation.xml";
    io.writexml(filename, props.Node.new({
        "PropertyList": {
            ___include: "Aircraft/c182s/Models/Human/parachuter.xml",
            "params": {
                "chute-state_p": chute.getPath()
            }
        }
    }));
    
    # Setup the model structure
    model.getNode("path", 1).setValue(filename);
    model.getNode("latitude-deg-prop", 1).setValue(m_latN.getPath());
    model.getNode("longitude-deg-prop", 1).setValue(m_lonN.getPath());
    model.getNode("elevation-ft-prop", 1).setValue(m_altN.getPath());
    model.getNode("heading-deg-prop", 1).setValue(m_hdgN.getPath());
    model.getNode("pitch-deg-prop", 1).setValue(m_pitchN.getPath());
    model.getNode("roll-deg-prop", 1).setValue(m_rollN.getPath());
    
    
    #
    # init position and spawn
    #
    m_latN.setValue(coord.lat());
    m_lonN.setValue(coord.lon());
    m_altN.setValue(coord.alt());
    m_hdgN.setValue(course-180);
    m_pitchN.setValue(90);
    m_rollN.setValue(0);
    chute.setValue(0);
    
    # notify any listeners that a new model has been added.
    model.getNode("load", 1).remove();
    setprop("/ai/models/model-added", ai.getPath());
    
    
    
    #
    # Animations
    #
    
    # calculate freefall duration
    var terrain_elev_ft = 3.28084 * geo.elevation(m_latN.getValue(), m_lonN.getValue());
    var openChuteAlt    = terrain_elev_ft+chute_open_ft;
    var freefall_s      = (m_altN.getValue() - openChuteAlt)/freefall_down_fps;
    if (freefall_s > 0) {
        #print("DBG: above chute open alt(cur["~m_altN.getValue()~"] > open["~openChuteAlt~"]; terrain@"~terrain_elev_ft~"): freefall for "~freefall_s~"s; "~model.getPath());
        var curalt = m_altN.getValue();
        interpolate(m_altN, 
            curalt, 0.15,
            curalt - freefall_down_fps*0.50, 1.00,
            curalt - freefall_down_fps*1.00, 0.75,
            openChuteAlt, freefall_s
        );
    } else {
        freefall_s = 0.01;
    }
    
    # Open chute and glide down after freefall
    var glide_s = (m_altN.getValue() - terrain_elev_ft)/chute_down_fps;
    settimer(func(){
        interpolate(m_pitchN, 0, 2.0);   # pitch down after freefall before chute opens
        interpolate(chute,    0, 2.0, 1, 3);  # open chute when vertically
        
        # Glide down
        interpolate(m_altN, terrain_elev_ft-7, glide_s);     # offset: sink in a bit, so only the chute is visible after landing
        #print("DBG: Chuteglide interpolation: cur="~m_altN.getValue()~"; tgt="~terrain_elev_ft~"; speed="~glide_s~"fps; "~model.getPath());
        
        #TODO: Wind affecting the glide down?
        #interpolate(m_latN, m_latN+windLatComp_tgt, glide_s);
        #interpolate(m_lonN, m_lonN+windLonComp_tgt, glide_s);
    }, freefall_s);
    
    
    #
    # Remove model after it hit the ground
    #
    var chute_remove_timer = maketimer(removeCheck_s, func(){
        #print("DBG: Chuteremoval checking: cur="~m_altN.getValue()~"; tgt="~terrain_elev_ft~"; speed="~glide_s~"fps; "~model.getPath());
        if (m_altN.getValue() <= terrain_elev_ft+5) {
            #print("DBG: Chuteremoval REMOVE: "~model.getPath());
            model.remove();
            ai.remove();
            chute_remove_timer.stop();
        }
    });
    chute_remove_timer.start();
}
