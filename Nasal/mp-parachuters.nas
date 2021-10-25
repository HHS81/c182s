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
    
    #
    # CONFIG
    #
    var path          = 'Models/Geometry/parachuter.xml';
    var down_fps      = 35;    # should be synced with submodel buoyancy value (value is not exaclty the same)
    var removeCheck_s = 50;    # check removal timer after landing
    
    
    
    
    #
    # Get remote spawn position
    #
    var coord = geo.Coord.new();
    coord.set_latlon(
        rplayer.getNode("position/latitude-deg").getValue(),
        rplayer.getNode("position/longitude-deg").getValue(),
        rplayer.getNode("position/altitude-ft").getValue()
    );
    var course = rplayer.getNode("orientation/true-heading-deg").getValue();
    
    # adjust spawn point relative to aircraft
    coord.set_alt(coord.alt() - 5.0);
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
    
    model.getNode("path", 1).setValue(path);
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
    m_hdgN.setValue(course);
    m_pitchN.setValue(0);
    m_rollN.setValue(0);
    
    # notify any listeners that a new model has been added.
    model.getNode("load", 1).remove();
    setprop("/ai/models/model-added", ai.getPath());
    
    
    #
    # Animations
    #
    
    interpolate(m_pitchN, -90, 3.5);   # Pitch down after jumping out
    
    # Glide down
    var terrain_elev_ft = 3.28084 * geo.elevation(m_latN.getValue(), m_lonN.getValue()) -20; # offset: sink in a bit, so only the chute is visible
    var s = (m_altN.getValue() - terrain_elev_ft)/down_fps;
    interpolate(m_altN, terrain_elev_ft, s);
    #print("DBG: Chutetimer interpolation: cur="~m_altN.getValue()~"; tgt="~terrain_elev_ft~"; speed="~s~"fps; "~model.getPath());
    
    
    #
    # Remove model after it hit the ground
    #
    var chute_remove_timer = maketimer(removeCheck_s, func(){
        #print("DBG: Chutetimer checking: cur="~m_altN.getValue()~"; tgt="~terrain_elev_ft~"; speed="~s~"fps; "~model.getPath());
        if (m_altN.getValue() <= terrain_elev_ft+5) {
            #print("DBG: Chutetimer REMOVE: "~model.getPath());
            model.remove();
            ai.remove();
            chute_remove_timer.stop();
        }
    });
    chute_remove_timer.start();
}
