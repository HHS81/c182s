###############################################################################
##
## Davtron 803
##
##  From Nasal for DR400-dauphin
##
##  dany93
##  Clément de l'Hamaide - PAF Team - http://equipe-flightgear.forumactif.com
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

##########################################
# Horameter / Chrono
##########################################

props.globals.initNode("/instrumentation/horameter/elapsed-time", 0, "INT");
props.globals.initNode("/instrumentation/chrono/elapsed-time", 0, "INT");

var chrono = aircraft.timer.new("/instrumentation/chrono/elapsed-time", 1);
var horameter = aircraft.timer.new("/instrumentation/horameter/elapsed-time", 1, 1);

setlistener("/instrumentation/horameter/running", func(running){
  if(running.getBoolValue()){
    horameter.start();
  }else{
    horameter.stop();
  }
});


var floor = func(v) v < 0.0 ? -int(-v) - 1 : int(v);
var elapsedTime = 0;
var formatedTime = "";
var sec = 0;
var min = 0;
var hrs = 0;

var timeFormat = func{

  elapsedTime = getprop("/instrumentation/chrono/elapsed-time");

  hrs = floor(elapsedTime/3600);
  min = floor(elapsedTime/60);
  sec = elapsedTime;

  formatedTime = sprintf("%02d:%02d:%02d", hrs, min-(60*hrs), sec-(60*min));
  setprop("/instrumentation/chrono/formated-time", formatedTime);

}