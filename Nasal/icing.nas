#############################################################################
# This file is part of FlightGear, the free flight simulator
# http://www.flightgear.org/
#
# Copyright (C) 2009 Torsten Dreyer, Torsten (at) t3r _dot_ de
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#############################################################################

#########################################################################################
# this are the helper functions to model structural icing on airplanes
# Maintainer: Torsten Dreyer (Torsten at t3r dot de)
#
# Simple model: we listen to temperature and dewpoint. If the difference (spread) 
# is near zero and temperature is below zero, icing may occour.
# 
# inputs
# /environment/dewpoint-degc
# /environment/temperature-degc
# /environment/effective-visibility-m
# /velocities/airspeed-kt
# /environment/icing/max-spread-degc       default: 0.1
#
# outputs
# /environment/icing/icing-severity        numeric value of icing severity
# /environment/icing/icing-severity-name   textual representation of icing severity one of
#                                          none,trace,light,moderate,severe
# /environment/icing/icing-factor          ammound of ice accumulation per NAM

#########################################################################
# implementation of the global icemachine
#########################################################################

var ICING_NONE     = 0;
var ICING_TRACE    = 1;
var ICING_LIGHT    = 2;
var ICING_MODERATE = 3;
var ICING_SEVERE   = 4;

# these are the names for the icing severities
var ICING_CATEGORY = [ "none", "trace", "light", "moderate", "severe" ];

# the ice accumulating factors. Inches per nautical air mile flown
var ICING_FACTOR = [
  # none: sublimating 0.3" / 80NM
  -0.3/80,

  # traces: 0.5" / 80NM
  0.5/80.0,

  # light: 0.5" / 40NM
  0.5/40.0,

  # moderate: 0.5" / 20NM
  0.5/20.0,

  #severe: 0.5" / 10NM
  0.5/10
];

# since we don't know the LWC of our clouds, just define some severities
# depending on temperature and a random offset
# format: upper temperatur, lower temperatur, minimum severity, maximum severity
var ICING_TEMPERATURE = [
  [ 999,   0, ICING_NONE,     ICING_NONE ],
  [   0,  -2, ICING_NONE,     ICING_MODERATE ],
  [  -2, -12, ICING_LIGHT,    ICING_SEVERE ],
  [ -12, -20, ICING_LIGHT,    ICING_MODERATE ],
  [ -20, -30, ICING_TRACE,    ICING_LIGHT ],
  [ -30, -99, ICING_TRACE,    ICING_NONE ]
];

var dewpointN     = props.globals.getNode( "/environment/dewpoint-degc" );
var temperatureN  = props.globals.getNode( "/environment/temperature-degc" );
var speedN        = props.globals.getNode( "/velocities/airspeed-kt" );
var icingRootN    = props.globals.getNode( "/environment/icing", 1 );
var visibilityN   = props.globals.getNode( "/environment/effective-visibility-m" );

var severityN     = icingRootN.initNode( "icing-severity", ICING_NONE, "INT" );
var severityNameN = icingRootN.initNode( "icing-severity-name", ICING_CATEGORY[severityN.getValue()] );
var icingFactorN  = icingRootN.initNode( "icing-factor", 0.0 );
var maxSpreadN    = icingRootN.initNode( "max-spread-degc", 0.1 );

var setSeverity = func {
  var value = arg[0];
  if( severityN.getValue() != value ) {
    severityN.setValue( value );
    severityNameN.setValue( ICING_CATEGORY[value] );
  }
}

#########################################################################################
# These are objects that are subject to icing
# inputs under /sim/model/icing/iceable (multiple instances allowed)
# ./name               # name of this object, more or less useless
# ./salvage-control    # name of a boolean property that salvages from ice
# ./output-property    # the name of the property where the ice amount is written to
# ./sensitivity        # a multiplier for the ice accumulation
#
# outputs
# ./ice-inches         # the amount of ice in inches OR
# [property named by output-property] # the amount of ice in inches
#########################################################################################
var IceSensitiveElement = {};

IceSensitiveElement.new = func {
  var obj = {};
  obj.parents = [IceSensitiveElement];
  obj.node = arg[0];

  obj.nameN = obj.node.initNode( "name", "noname" );
  var n = obj.node.getNode( "salvage-control", 0 );
  obj.controlN = nil;
  if( n != nil ) {
    n = n.getValue();
    if( n != nil ) {
      obj.controlN = props.globals.initNode( n, 0, "BOOL" );
    }
  }
  obj.sensitivityN = obj.node.initNode( "sensitivity", 1.0 );

  obj.iceAmountN = nil;
  n = obj.node.getNode( "output-property", 0 );
  if( n != nil ) {
    n = n.getValue();
    if( n != nil ) {
      obj.iceAmountN = props.globals.initNode( n, 0.0 );
    }
  }
  if( obj.iceAmountN == nil ) {
    obj.iceAmountN = obj.node.initNode( "ice-inches", 0.0 );
  }

  return obj;
};

#####################################################################
# this gets called from the icemachine on each update cycle
# arg[0] is the time in seconds since last update
# arg[1] is the number of NAM traveled since last update
# arg[2] is the ice-accumulation-factor for the current severity
#####################################################################
IceSensitiveElement.update = func {
  if( me.controlN != nil and me.controlN.getBoolValue() ) {
    if( me.iceAmountN.getValue() != 0.0 ) {
      me.iceAmountN.setDoubleValue( 0.0 );
    }
    return;
  }

  var deltat  = arg[0];
  var dist_nm = arg[1];
  var factor  = arg[2];

  var v = me.iceAmountN.getValue() + dist_nm * factor * me.sensitivityN.getValue();
  if( v < 0.0 ) {
    v = 0.0;
  }
  if( me.iceAmountN.getValue() != v ) {
    me.iceAmountN.setValue( v );
  }
};

#####################################################################
# read the ice sensitive elements from the config file
#####################################################################
var iceSensitiveElements = nil;

var icingConfigN = props.globals.getNode( "/sim/model/icing", 0 );
if( icingConfigN != nil ) {
  iceSensitiveElements = [];
  var iceableNodes = icingConfigN.getChildren( "iceable" );
  foreach( var iceable; iceableNodes ) {
    append( iceSensitiveElements, IceSensitiveElement.new( iceable ) );
  }
};

#####################################################################
# the time triggered loop
#####################################################################
var elapsedTimeNode = props.globals.getNode( "/sim/time/elapsed-sec" );
var lastUpdate = 0.0;
var icing = func {

  var temperature = temperatureN.getValue();
  var severity = ICING_NONE;
  icingFactorN.setDoubleValue( ICING_FACTOR[severity] );

  var visibility = 0;
  if( visibilityN != nil ) {
    visibility = visibilityN.getValue();
  }

  # check if we should create some ice
  var spread = temperature - dewpointN.getValue();
  if( spread < maxSpreadN.getValue() and visibility < 1000 ) {
    for( var i = 0; i < size(ICING_TEMPERATURE); i = i + 1 ) {
      if( ICING_TEMPERATURE[i][0] > temperature and 
          ICING_TEMPERATURE[i][1] <= temperature ) {
        var s1 = ICING_TEMPERATURE[i][2];
        var s2 = ICING_TEMPERATURE[i][3];
        var ds = s2 - s1 + 1;
        severity = s1 + int(rand()*ds);
        icingFactorN.setDoubleValue( ICING_FACTOR[severity] );
        break;
      }
    }
  } else {
    # clear air
    # melt ice if above freezing temperature
    # the warmer, the faster. Lets guess that at 10degc
    # 0.5 inch goes in 10miles
    if( temperature > 0.0 ) {
      icingFactorN.setDoubleValue( factor = -0.05 * temperature / 10.0 );
    }
    # if temperature below zero, sublimating factor is initialized
  }

  setSeverity( severity );

  # update all sensitive areas
  var now = elapsedTimeNode.getValue();
  var dt = now - lastUpdate;
  foreach( var iceable; iceSensitiveElements ) {
    iceable.update( dt, dt * speedN.getValue()/3600.0, icingFactorN.getValue() );
  }

  lastUpdate = now;
  settimer( icing, 2 );
}

#####################################################################
# start our icemachine
# don't care if there is nothing to put ice on
#####################################################################
if( iceSensitiveElements != nil ) {
  lastUpdate = elapsedTimeNode.getValue();
  icing();
}
#####################################################################
