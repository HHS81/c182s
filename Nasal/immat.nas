io.include("Aircraft/c182s/Nasal/registration_number.nas");

var refresh_immat = func {
    var immat = props.globals.getNode("sim/model/immat",1).getValue();
    set_registration_number(props.globals, immat);
};

var immat_dialog = gui.Dialog.new("/sim/gui/dialogs/c182s/status/dialog",
                  "Aircraft/c182s/gui/dialogs/immat.xml");

setlistener("/sim/signals/fdm-initialized", func {
    print("[IMMAT-DBG] fdm-initialized");
    var immat    = props.globals.getNode("sim/model/immat", 1);
    var callsign = props.globals.getNode("sim/multiplay/callsign").getValue();

    if (callsign != "callsign")
        immat.setValue(callsign);
    else
        immat.setValue("");

    setlistener("sim/model/immat", refresh_immat, 1, 0);
});
