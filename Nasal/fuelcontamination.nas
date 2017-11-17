##########################################
# Fuel Contamination
# TODO: It would be cool if contamination chance would be influenced by environment properties and by tank filling levels
##########################################
var init_fuel_contamination = func {
    if (getprop("/engines/engine/complex-engine-procedures") and getprop("/engines/engine/allow-fuel-contamination")) {
        var chance = rand();
        # Chance of contamination is 1 %
        if (chance < 0.01) {
            # Quantity of water is much more likely to be small than large, since
            # it's given by x^6 (76 % of the time it will be lower than 0.2)
            var water = math.pow(rand(), 6);

            setprop("/consumables/fuel/tank[0]/water-contamination", water);

            # level of water in the right tank will be the same as in the left tank +- 0.1
            water = water + 0.2 * (rand() - 0.5);
            water = std.max(0.0, std.min(water, 1.0));
            setprop("/consumables/fuel/tank[1]/water-contamination", water);
            
        } else {
            setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);
            setprop("/consumables/fuel/tank[1]/water-contamination", 0.0);
        };
        
        
        # Water in fuel stainer and selector valve can differ but chance should be somewhat lower
        var selectorValveChance = rand();
        if (selectorValveChance < 0.008) {
            var selV_water = math.pow(rand(), 6);
            setprop("/consumables/fuel/tank[2]/water-contamination", selV_water);
        };
        var strainerChance = rand();
        if (strainerChance < 0.008) {
            var strainerwater = math.pow(rand(), 6);
            setprop("/consumables/fuel/tank[3]/water-contamination", strainerwater);
        };
        
        
        print("fuel contamination initialized");
        
    };
};

##########################################
# Reset fuel contamination
##########################################
var reset_fuel_contamination = func() {
    print("reset fuel contamination");
    setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[1]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[2]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[3]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[0]/sample-water-contamination", 0.0);
    setprop("/consumables/fuel/tank[1]/sample-water-contamination", 0.0);
    setprop("/consumables/fuel/tank[2]/sample-water-contamination", 0.0);
    setprop("/consumables/fuel/tank[3]/sample-water-contamination", 0.0);
};

##########################################
# Take Fuel Sample
##########################################
var take_fuel_sample = func(index) {
    var fuel = getprop("/consumables/fuel/tank", index, "level-gal_us");
    var water = getprop("/consumables/fuel/tank", index, "water-contamination");

    # Remove 50 ml of fuel
    setprop("/consumables/fuel/tank", index, "level-gal_us", fuel - 0.0132086);

    # Remove a bit of water if contaminated
    if (water > 0.0) {
        var sample_water = std.min(0.2, water);
        water = water - sample_water;
        setprop("/consumables/fuel/tank", index, "water-contamination", water);
        setprop("/consumables/fuel/tank", index, "sample-water-contamination", sample_water);
    };
};

##########################################
# Return Fuel Sample
##########################################
var return_fuel_sample = func(index) {
    
    # Stainer/Seelctor: Water and fuel needs to be added back to right tank instead of strainer/selector valve
    if (index >=2 ) {
        # lets fake "sampled" water in right wing tank :)
        var tankIndex = 1;
        var tankSamplewater = getprop("/consumables/fuel/tank", tankIndex, "sample-water-contamination");
        var sample_water = getprop("/consumables/fuel/tank", index, "sample-water-contamination");
        tankSamplewater = tankSamplewater + sample_water;
        
        setprop("/consumables/fuel/tank", tankIndex, "sample-water-contamination", tankSamplewater);
        setprop("/consumables/fuel/tank", index, "sample-water-contamination", 0.0);
        return_fuel_sample(1);
        
        return;
    };

    
    # Wing tanks:
    var fuel = getprop("/consumables/fuel/tank", index, "level-gal_us");
    var water = getprop("/consumables/fuel/tank", index, "water-contamination");
    var sample_water = getprop("/consumables/fuel/tank", index, "sample-water-contamination");

    # Add back the 50 ml of fuel
    setprop("/consumables/fuel/tank", index, "level-gal_us", fuel + 0.0132086);

    # Add back the (contaminated) water
    if (sample_water > 0.0) {
        water = water + sample_water;
        setprop("/consumables/fuel/tank", index, "water-contamination", water);
        setprop("/consumables/fuel/tank", index, "sample-water-contamination", 0.0);
    };
}; 
