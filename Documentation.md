Cessna 182S - Documentation
===========================

This file describes some of the advanced simulation options available.
They allow following the operations and procedures laid out in the Pilot operations Handbook (POH) in great detail
and a realistical manner.  
A copy of the POH can usually be found online, for example: http://tssflyingclub.org/documents/C182S_POH.pdf  
The checklist is included there too, but also available ingame (below `help`). For printout, a PDF is generated from this data
[and distributed with the aircraft sources](c182s-checklist.pdf).


Advanced Aircraft options
-------------------------

### Enable Fog and Frost
When activated, the cabin temperature and humidity can cause the windshield to fog up. If the cabin temperature
is low enough, frost wil appear instead. Cabin humidity and temperature is affected by the passengers and outside
weather conditions (the Davtron shos OAT) and can be controlled with the `air`-, `heat`- and `defrost levers` in the right lower pat of the cockpit.
To mitigate fog or frost, you must lower the windshields humidity below the dewpoint which can be usually easily achieved
by adjusting the defrost-lever.  
If it is too cold or too hot, the pilot will complain about it (text messages appear). You then need to adjust the `heat`- and
`air lever`. Hot air is produced by the engine, so EGT is a measure for how much hot air is available. The Levers and text
messages will give a hint on the condition and also the trend (give it some time to respond to changes, however).
Opening the windows may also be an option to cool down quickly.  
If the text messages annoy you, you can disable them by unchecking the `Show hint messages` checkbox.


### Complex engine procedures
Unchecking `Complex engine procedures and failures` allows a fairly basic engine mode where no priming is needed (just activate
battery, apply enough mixture and press `s` to start), and no further damage can occur.  
Otherwise you need to pay attention to varios engine related things:
- Priming for startup  
  The priming procedure involves applying some fuel into the manifold by the fuel pump. The exact procedure is laid out in the checklist.
  The engine can be easily flooded, especially in cold weather (remedy actions also in the POH/Checklist).
  If the oil is too cold, you should apply the preheater first, making priming more easy.
- Engine cooling and overheating  
  CHT and oil temps can lead to excessive friction (loss of power) and also engine failure. Watch CHTs and respect engine limits.
  Be sure to warm the engine before attempting takeoff.
- `Allow Fuel Contamination`  
  This simulates water in the fuel, so be sure to follow the preflight checklist correctly. Otherwise the engine may
  not start or cough withoput developing full power.
- `Allow Oil Management`  
  When activated, the engine will actually consume oil, so check its level before starting the engine. If the oil level gets critical (< 4 qts),
  the oil pump will not be able to supply enough pressure for good lubrication, leading to engine failure. Also monitor the oil service time as
  old oil does not perform so well (cycle it about every 50 hrs).
  Also some effects like additional friction with too hot oil and cold-start will be simulated.
- `Allow Spark plug icing`  
  If active, the spark plugs can freeze over, preventing engine start. This can occur in cold weather if the engine starts and quits shortly after, because then the engine is still cold, letting the water produced by the combustion process condensate on the plugs where they freeze over. This will prevent furter engine starts. To prevent this, preheat the engine properly, and if it happened, heat the engine so the ice melts (which can take considerable time!)
- `Winter Kit`  
  The winter kit is needed in cold weather (<20°F/-6°C) to reduce cooling air flow. If not supplied, the engine will possibly not get warm enough to develop good power, but be sure to remove it in hot weather, otherwise you risk too high CHT temps.

### Autostart
The c182 features an autostart- and autoshutdown option which can be used to quickly start/stop the engine. The corresponding checklist items
will be run trough, so for example autostart will take care of removing tiedowns and check fuel contamination for you, as well as ensuring good battery, enough oil and fuel. Shutdown will secure the airplane on the ground.

### State system
The plane supports a sophisticated state system that let you quickly set up some interesting training scenarios like approach/landing.
The states can be selected from FGFS launcher but also on commandline. Those always override the ingame selection.  
When starting from commandline, you can select any state with the `--state=...` parameter.
Starting from commandline without supplying a state will yield the last selected ingame state option.

The following states are available currently:
* `--state=saved` All levers etc. are where you left them.
* `--state=auto` Automatically set state depending on position (in-air=cruise; parking=parking any other=take-off).
* `--state=parking` Cold-And-Dark as well as secured to ground; before preflight checks.
* `--state=take-off` Ready for Takeoff with engine idling.
* `--state=cruise` Engine on and set to cruise (use with in-air-start)
* `--state=approach` Engine on and set to cruise (use with in-air-start)
With an in-air-start, airspeed gets initialized to 100kts unless otherwise specified >0 (e.g. `--vc=5`).

Examples:
* _Approach to EDDM:_ `fgfs --aircraft=c182s --state=auto --airport=EDDM --offset-distance=6 --altitude=3500 --timeofday=noon`
* _Power-off Approach to EDDM:_ `fgfs --aircraft=c182s --state=take-off --airport=EDDM --offset-distance=6 --altitude=3500 --timeofday=noon` (engine idles; `--state=parking` state gives the funny experience of gliding with all <s>hope</s> power lost and blocked pitot)


### Engine failure simulation
In the aircraft menu you can select `Extended failures`. This brings up a dialog in which you can fail most aircraft systems and equipment. If you wish, you can also have failures be restored in your next session, but be aware this only works reliably with the saved and parked state, because take-off and cruise will set the aircraft in an repaired state (as would be assumed by running the checklists properly beforehand).
You have also convinient access to FGFS default failures from there.  
By default, the simulation will print a red text showing that a component failed, informing the pilot. You can turn off that message with the `Display failure messages on screen` checkbox.

Note that several failures might ultimatively lead to engine failure, like a broken oil pump. A tripped breaker indicates some problem in the electric system, so just resetting it may cause the electrical bus to fail completely, usually worsening the problem.

The simulation is quite detailed, so a failed gauge does not neccesarily mean a failed system (no oil pressure? maybe its just the gauge?).

#### Surprise modes
The plane has also two surprise modes that can enrich you flying experience and allows training of emergency situations (without knowing what
and when something fails).
1. _Random failure mode:_
   Use this to fail a defined ammount of failures until a maximum time is reached. It is not guaranteed that all failures will trigger (but most will!).
2. _Random surprise mode:_
   Fail a random system in a fixed time interval.

The surprise modes can be activated at startup from commandline. You can add, adjust and uncomment this to your launcher:
```
# Init failure modes in case requested by startup.
# This can be done by providing the following properties through the laucher or cli:
#  + random failures (fail at most n systems in max x time)
#     --prop:/sim/failure-manager/surprise-mode/ammount=<number>
#     --prop:/sim/failure-manager/surprise-mode/maxtime=<minutes> (optional, default 30)
#
#  + random surprise mode (fail one system every x minutes): 
#     --prop:/sim/failure-manager/surprise-mode/timer-active=1
#     --prop:/sim/failure-manager/surprise-mode/timer=<minutes>  (optional, default 30)
#
#  To also turn off screen messages, use:
#     --prop:/sim/failure-manager/quiet=1
#
```

### Icing
When flying into icing conditions (high humidity and low temperatures, esp. in clouds) the plane may ice.
This can add drag and affect aircraft performance, as well as raising the stall speed to unexpected values.
The pitot tube and stall horn can ice too, so you might not get any warning of a imminent stall anymore. Activate the
`pitot-heat` switch to melt the ice, the stall warning vane is also linked to this switch.

### Various advanced runtime properties
Some properties can be set at runtime to adjust the simulators state. You may use this for example in a script or trough a telnet session.  
Additionally to the default ones, the c182 knows the following:
- `/fdm/jsbsim/systems/propulsion/manual-friction` (in horsepowers) to induce additional engine friction, which reduces power.
- `/engines/engine/kill-engine` immediately kills the engine if set to `1`.

### KAP 140 Autopilot
The C182S features a highly detailed and realistic Bendix/Kind KAP 140 Autopilot. You can operate it like described in the manufacturers POH.  
A [quick introduction is in the FGFS-wiki](https://wiki.flightgear.org/Bendix/King_KAP140_Autopilot).

- The AP can be activated by pressing and holding the "AP" key on the instrument. Note that the AP only activates after the automatic preflight checks are complete (`PFT n` in display). During these checks, various annunciators will illuminate. The AP will only engage after those are vanished.
- After the PFT, you are prompted to enter a barometric pressure by a flashing `29.92` setting in the top right corner. The AP will not allow to be engaged until it is initialized.
- The autopilot features a disconnect knob which is accessible by pressing `SHIFT-D`; the AP will disconnect and stay off.
- Temporarily disconnect ("CWS") can be activated by pressing the `d` key. After release the AP will continue with its program.
- Severe turbolences may trigger the over-g disconnect safety.


### Aerotowing gliders
The C182S and C182T are equipped with an tow hook and can tow any JSBSim/YASIM glider compatible to FlightGears standard implementation.

Once the glider pilot hooked into your Cessna, you can press `SHIFT-O` to release the hook. For connecting, get close infront of the glider. When accelerating, do it with caution, otherwise the rope my rip. Expect also other airplane behaviour when towing (longer takeoff roll, etc).


FAQ
---
Most of the [C172p's FAQ](http://wiki.flightgear.org/Cessna_172P#FAQ) also applies to the 182, so also read those.
1. The engine won't start - what to do?  
   You most probably did not prime correclty. Either there is not enough prime, or you flooded the engine. Follow the _engine flooded_ procedure to clean the manifold, and then (if engine did not fire) again prime. Also check fuel contamiation. As a last resort, try the `autostart` option.
2. I can't see outside, everything is grey!  
   Either you are in a cloud or your windows are foggy. Open the windows to let damp out, and adjust the defrost, air and heat cabin levers.
3. The plane does not move straight, whats that?  
   You are experiencing simulated forces of torque and wind from the propeller. Apply some rudder to mitigate.
4. Why does the Autostart fail to start the engine?  
   This should never happen. Please file a bug report at the github project site.
5. Why does the engine die immediately after startup?  
   Most probably the engine is too cold and you advanced the throttle too fast. Warm the engine at about 1000rpm for some more time. Other sources may
   be contaminated fuel or a damaged engine.
6. The glareshield, pedestal and interior lights are not working. Is there a bug?
   Most probably you just need to enable ALS and move the model shader slider to the right (check extended settings!) in your graphic settings.
