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

When starting cold&dark in freezing temperatures, the plane may freeze over. In this case you need to clean it (see aircraft options dialog).
To prevent this, you should apply the plane cover when securing your craft.


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
  Be sure to properly warm the engine before attempting takeoff. After takeoff, reduce power to CLIMB checklist when obstacles are cleared.
- `Allow Fuel Contamination`  
  This simulates water in the fuel, so be sure to follow the preflight checklist correctly. Otherwise the engine may
  not start or cough withoput developing full power.
- `Allow Oil Management`  
  When activated, the engine will actually consume oil, so check its level before starting the engine. If the oil level gets critical (< 4 qts),
  the oil pump will not be able to supply enough pressure for good lubrication, leading to engine failure. Also monitor the oil service time as
  old oil does not perform so well (cycle it about every 50 hrs).
  Also some effects like additional friction with too hot oil and cold-start will be simulated.
- `Allow Spark plug icing/fouling`  
  If active, the spark plugs can freeze over, preventing engine start. This can occur in cold weather if the engine starts and quits shortly after,
  because then the engine is still cold, letting the water produced by the combustion process condensate on the plugs where they freeze over. This
  will prevent furter engine starts. To prevent this, preheat the engine properly, and if it happened, heat the engine so the ice melts (which can
  take considerable time!)  
  Also, if the combustion temperature is too low and/or or the mixture too rich, the spark plugs can slowly foul with lead and carbon deposits,
  eventually shortening the electrical spark. Be sure to keep the engine (CHT) warm enough by proper leaning and run-up procedures. In short, keep
  the combustion temperature above about 264°C/507°F and avoid idling too long at <1000 RPM. Also, lean to peak EGT on ground/taxi and warm-up the
  engine at 1200 RPM. Should a magneto check reveal spark plug problems, its most of the time some fouled plugs. Put the engine to 1800 RPM and 50°
  lean of peak EGT. Let it run for about 30 seconds, monitor CHT. This should clean the deposits which a second magneto check should verify.  
When parking the plane after flight, you should go to 1800 RPM and lean mix for 20 secs, then reduce throttle to 1000 RPM and then stop the engine by pulling mixture to the cut-off position.
- `Allow starter cycle limits`  
  If active, you need to observe the starter cycle, otherwise you risk burning trough the engine starter.
- `Winter Kit`  
  The winter kit is needed in cold weather (<20°F/-6°C) to reduce cooling air flow. If not supplied, the engine will possibly not get warm enough to develop good power, but be sure to remove it in hot weather, otherwise you risk too high CHT temps.

### Realistic Instruments
When this option is activated, some instruments will be simulated more realistically.  
The gyro based instruments will need more time to spin up fully (2-3 minutes), so for example give the HI/DG time before trying to calibrate it. Also, excess forces (steep turns, high G-loads) can introduce errors or even induce tumbling of the gyro.  
The HI will be affected by some expected errors like precession due to earths rotation, as well as transport wander, so you need to check and recalibrate the instrument every 15 minutes or so.

The magnetic compass can get stuck.

Avionics can overheat (and fail) in very hot weather and/or failed avionics fan.

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

The plane tries to stabilize itself for some seconds after sim startup when starting in air. To disable this feature, supply `--prop:/sim/inair-startup-stabilizer=0` in your launcher.

Examples:
* _Approach to EDDM:_ `fgfs --aircraft=c182s --state=auto --airport=EDDM --offset-distance=6 --altitude=3500 --timeofday=noon`
* _Power-off Approach to EDDM:_ `fgfs --aircraft=c182s --state=take-off --airport=EDDM --offset-distance=6 --altitude=3500 --timeofday=noon` (engine idles; `--state=parking` state gives the funny experience of gliding with all <s>hope</s> power lost and blocked pitot)


### Extended failure simulation
In the aircraft menu you can select `Extended failures`. This brings up a dialog in which you can fail most aircraft systems and equipment. If you wish, you can also have failures be restored in your next session, but be aware this only works reliably with the saved and parked state, because take-off and cruise will set the aircraft in an repaired state (as would be assumed by running the checklists properly beforehand).
You have also convinient access to FGFS default failures from there.  
By default, the simulation will print a red text showing that a component failed, informing the pilot. You can turn off that message with the `Display failure messages on screen` checkbox.

Note that several failures might ultimatively lead to engine failure, like a broken oil pump. A tripped breaker indicates some problem in the electric system, so just resetting it may cause the electrical bus to fail completely, usually worsening the problem.

The simulation is quite detailed, so a failed gauge does not neccesarily mean a failed system (no oil pressure? maybe its just the gauge?).

#### Surprise modes
The plane has also two surprise modes that can enrich you flying experience and allows training of emergency situations (without knowing what
and when something fails).
1. _Random failure mode:_
   Use this to fail a defined amount of failures until a maximum time is reached. It is not guaranteed that all failures will trigger (but most will!).
2. _Random surprise mode:_
   Fail a random system in a fixed time interval.

The surprise modes can be activated at startup from commandline. You can add, adjust and uncomment this to your launcher:
```
# Init failure modes in case requested by startup.
# This can be done by providing the following properties through the laucher or cli:
#  + random failures (fail at most n systems in max x time)
#     --prop:/sim/failure-manager/surprise-mode/amount=<number>
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
- `/engines/engine/manual-roughness-factor` (`0.0` to `1.0`) to induce engine roughness
- `/engines/engine/manual-power-reduction-pct` (`0.0` to `1.0`) to make the engine less efficient
- `/engines/engine/kill-engine` immediately kills the engine if set to `1`.
- `/fdm/jsbsim/heat/init-moisture` (`0.0` to `1.0`) quick-induce fog/frost. The setting will be hold indefinitely, so reset to `0`.

### KAP 140 Autopilot
The C182S features a highly detailed and realistic Bendix/Kind KAP 140 Autopilot. You can operate it like described in the manufacturers POH.  
A [quick introduction is in the FGFS-wiki](https://wiki.flightgear.org/Bendix/King_KAP140_Autopilot).

- The AP can be activated by pressing and holding the "AP" key on the instrument. Note that the AP only activates after the automatic preflight checks are complete (`PFT n` in display). During these checks, various annunciators will illuminate. The AP will only engage after those are vanished.
- After the PFT, you are prompted to enter a barometric pressure by a flashing `29.92` setting in the top right corner. The AP will not allow to be engaged until it is initialized.
- The autopilot features a disconnect knob which is accessible by pressing `SHIFT-D`; the AP will disconnect and stay off.
- Temporarily disconnect ("CWS") can be activated by pressing the `d` key. After release the AP will continue with its program.
- Severe turbolences may trigger the over-g disconnect safety.


### Davtron 803 digital clock
The Davtron M803 digital clock displays various information to the pilot. The clock is turned on automatically when the master battery switch is engaged.

The LCD top row can show outside air temperature (OAT) in Fahrenheit and Celsius, and also the current battery voltage. Cycling between these is available by pushing the top button.

The lower LCD row displays four different timing information, the active mode is currently highlighted left via a blinking annunciator: UTC-Time (UT), Local-Time (LT), Elapsed flight time (FT) and a elapsed time counter (ET).

- Flight timer (FT):
  - The flight timer starts counting as soon as power is applied. To reset the timer, push and hold the _control_ button for at least 3 seconds (display will show `99:59` and reset the flight timer once button is released).
  - You can setup an alarm for reaching a future flight time (audible tone and flashing display) by pressing the _select_ and _control_ buttons together (**shift-click one of the two buttons**). This will enter the setup mode: the currently selected digit will blink, you can cycle it with the _control_ knob. If you are satisfied, the _select_ button will bring you to the next digit. When all four digits are confirmed, the alarm is armed automatically.
- Elapsed timer (ET):
  - The elapsed timer starts when you selected ET mode and then push the _control_ button. The next button press stops the timer. Another press resets it to zero.
  - You can setup an countdown timer by by pressing the _select_ and _control_ buttons together (**shift-click one of the two buttons**). Enter the digits like just described at the FT alarm mode. After confirming the last digit, the countdown is armed and ready to be started by another press of _control_. The alarm will go off once the countdown reaches zero. You can confirm the the alarm by either pressing _select_ or _control_.

### KR87 ADF receiver
The Bendix/King KR87 ADF receiver can tune into NDBs. It also features two timers, which can be cycled by pressing the `FLT/ET` button.

- Flight timer (FT):
  - It starts counting upwards as soon as the unit receives power.
  - It cannot be reset, despite momentarily switching the unit off.
  - In addition to the Davtron 8003s FT timer (which can be reset) this might serve as a "total flight time timer".
- Elapsed timer (ET):
  - It starts counting upwards as soon as the unit receives power.
  - Can be reset to `00:00` by shortly pressing the `SET/RST` button.
  - Pressing `SET/RST` for more than two seconds will enter the _Set_-mode (indicated by flashing `ET` annunciator) for _ET countdown mode_:
    - with the inner and outer knobs you can adjust the time.
    - shortly pressing the `SET/RST` button will activate the countdown.
    - Once the timer reaches `00:00`, the display will switch to `ET` mode and flash the digits for about 15 seconds. Also, an aural alarm is activated for about one second. The timer continues to count upwards when crossing `00:00`.

When either of the two timer modes is active (`FT` or `ET` is annunctiated and right display shows time), turning the inner or outer knob will directly tune the _selected_ frequency. This might be useful to scan for stations.  
You can return to the normal standby-tuning mode by shortly pressing the `FRQ` button.

### KN62A DME
The Bendix/King KN62A DME allows you to get measurements to a tuned VOR station and displays _distance_, _speed_ and _estimated time_ to the station.  
It features a primary mode (`RMT`) which is autmatically slaved to NAV1.  
Changing the mode to `FREQ` allows you to adjust the secondary frequency using the inner and outer frequency selection knobs (while in `FREQ` mode, the distance to the station is displayed, so you can see if you have reception.).  
Finally, the `GS/T` mode locks the secondary frequency selection and displays _distance_, _speed_ and _estimated time_ to the secondary station.

This way, you can scan for stations and get information about a station without the need to retune NAV1.

### GMA 340 FGCom integration ###
If enabled, this integrates the GMA 340 audio panel with FGCom. Most notably, you can select the radio on which you want to transmit by pressing the respective COM/MIC button. Only one can be active for transmission. If you press the FGCOM PTT button (`space`), you will transmit over the selected radio, which indicates a blinking led.

### Dual Control feature
You can join a remote pilot as copilot! The pilot just uses the normal C182S Aircraft while the copilot must start the special "CoPilot" aircraft variant (select from the launcher).

Once connected to the multiplayer server, both select each other trough the multiplayer menu entry *Select dual-control MP-pilot*:
- Upon selection, the CoPilot instance will switch into the copilot seat.
- Once the pilot selected the copilot too, he will send its full state to the copilot, so he sees most instruments etc.

### Aerotowing gliders
The C182S and C182T are equipped with an tow hook and can tow any JSBSim/YASIM glider compatible to FlightGears standard implementation.

Once the glider pilot hooked into your Cessna, you can press `SHIFT-O` to release the hook. For connecting, get close infront of the glider. When accelerating, do it with caution, otherwise the rope my rip. Expect also other airplane behaviour when towing (longer takeoff roll, etc).


### Skydiving plane
In the Aircraft options menu you can reconfigure the plane to haul up skydivers. This will remove the seats and the door.
When on target altitude, just click on the passengers to make them jump out. Alternatively, you can use the "Jump!" button
from the aircraft options menu to make them all jump out one after another.  
Only passengers inside the plane will jump out, so add them using the "fuel and payload" settings dialog.  
Jump procedure is that they will crawl outside to the strut, then release; so plan for the drag.


Engine lever operation
----------------------
The Throttle, Prop and Mixture control levers can be operated either by keyboard,
by mouse dragging or by mouse wheel (when pointing on the lever and turning the wheel):

- Big adjustments: press `shift` while normal operation.
- Medium adjustments are done by just operating the levers.
- Small adjustments: press `alt` while normal operation. This simulates the Throttle friction lock and vernier features of the prop and mixture.


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
   Most probably the engine is too cold and you advanced the throttle too fast. Warm the engine at about 1200rpm for some more time. Other sources may
   be contaminated fuel, a damaged engine or fouled spark plugs.
6. The glareshield, pedestal and interior lights are not working. Is there a bug?
   Most probably you just need to enable ALS and move the model shader slider to the right (check extended settings!) in your graphic settings.
7. Engine power is not so good, especially on one magneto. What should I do?  
   Most probably you experience spark plug fouling. You let the engine get too cold by not leaning properly or excessive engine cooling. Better observe your mixture leaning, power and cowl flaps setting. On ground, don't let the plane idle on full rich, but set RPM to 1200 and lean to peak EGT. For Taxiing, reduce power unless paying extra for brakes is no issue :).  
   To remove the deposits on the spark plugs: put the engine to 1800 rpm and lean to peak EGT; let it run for about half a minute and repeat the mag check; repeat procedure if needed.
