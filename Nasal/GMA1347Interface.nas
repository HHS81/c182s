# Copyright 2021 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# Emesary interface to interface with the GMA1347 audio panel.
#

var GMA1347Interface = {

new : func ()
{
  var obj = { parents : [ GMA1347Interface ] };

  # Emesary
  obj._recipient = nil;
  obj._transmitter = emesary.GlobalTransmitter;
  obj._registered = 0;

  obj._com1 = globals.props.getNode("/instrumentation/audio-panel/com[0]", 1);
  obj._com1mic = globals.props.getNode("/instrumentation/audio-panel/com-mic[0]", 1);

  obj._com2 = globals.props.getNode("/instrumentation/audio-panel/com[1]", 1);
  obj._com2mic = globals.props.getNode("/instrumentation/audio-panel/com-mic[1]", 1);

  # The G1000 separates the selected COM radio (being modified) from the radio being listened to.
  obj._com_selected = globals.props.getNode("/instrumentation/audio-panel/audio-com-selected", 1);
  obj._com_selected.setIntValue(obj._com1mic.getBoolValue() ? 1 : 2);

  obj._nav1 = globals.props.getNode("/instrumentation/nav[0]/ident", 1);
  obj._nav2 = globals.props.getNode("/instrumentation/nav[1]/ident", 1);
  obj._dme = globals.props.getNode("/instrumentation/dme[0]/ident", 1);
  obj._hisense = globals.props.getNode("/instrumentation/audio-panel/hi", 1);
  obj._mkrmute = globals.props.getNode("/instrumentation/audio-panel/mkr", 1);
  obj._spkr = globals.props.getNode("/instrumentation/audio-panel/spkr", 1);

  return obj;
},


handleCOM1MIC : func(value) { 
    me._com_selected.setIntValue(1);
    me._com1.setBoolValue(1);
    me._com1mic.setBoolValue(1);
    me._com2.setBoolValue(0);
    me._com2mic.setBoolValue(0);
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleCOM2MIC : func(value) { 
    me._com_selected.setIntValue(2);
    me._com1.setBoolValue(0);
    me._com1mic.setBoolValue(0);
    me._com2.setBoolValue(1);
    me._com2mic.setBoolValue(1);
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleCOM3MIC : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
handleCOM12   : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
handlePA     : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
    
handleMKRMUTE : func(value) { 
    me._mkrmute.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},
    
handleDME     : func(value) { 
    me._dme.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleADF     : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not implemented - optional ADF is not implemented in FG1000
handleAUX     : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
handleMANSQ   : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not implemented
handlePILOT   : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not implemented

handleCOM1    : func(value) { 
    me._com1.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleCOM2    : func(value) { 
    me._com2.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleCOM3    : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
handleTEL     : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not used on Cessna Nav III
handleSPKR    : func(value) { 
    me._spkr.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleHISENS  : func(value) { 
    me._hisense.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleNAV1    : func(value) { 
    me._nav1.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handleNAV2    : func(value) { 
    me._nav2.toggleBoolValue();
    return emesary.Transmitter.ReceiptStatus_Finished;
},

handlePLAY    : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not implemented
handleCOPLT   : func(value) { return emesary.Transmitter.ReceiptStatus_NotProcessed; },  # Not implemented

RegisterWithEmesary : func()
{
  if (me._recipient == nil){
    me._recipient = emesary.Recipient.new("GMA1347Interface");
    var controller = me;

    # Note that unlike the various keys, this data isn't specific to a particular
    # Device - it's shared by all.  Hence we don't check for the notificaiton
    # Device_Id.
    me._recipient.Receive = func(notification)
    {

      if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
          notification.Event_Id == notifications.PFDEventNotification.HardKeyPushed and
          notification.EventParameter != nil)
      {
        var id = notification.EventParameter.Id;
        var value = notification.EventParameter.Value;

        if (id == fg1000.FASCIA.COM1MIC )   return controller.handleCOM1MIC(value);
        if (id == fg1000.FASCIA.COM1MIC ) return controller.handleCOM1MIC(value);
        if (id == fg1000.FASCIA.COM2MIC ) return controller.handleCOM2MIC(value);
        if (id == fg1000.FASCIA.COM3MIC ) return controller.handleCOM3MIC(value);
        if (id == fg1000.FASCIA.COM12 ) return controller.handleCOM12(value);
        if (id == fg1000.FASCIA.PA ) return controller.handlePA(value);
        if (id == fg1000.FASCIA.MKRMUTE ) return controller.handleMKRMUTE(value);
        if (id == fg1000.FASCIA.DME ) return controller.handleDME(value);
        if (id == fg1000.FASCIA.ADF ) return controller.handleADF(value);
        if (id == fg1000.FASCIA.AUX ) return controller.handleAUX(value);
        if (id == fg1000.FASCIA.MANSQ ) return controller.handleMANSQ(value);
        if (id == fg1000.FASCIA.PILOT ) return controller.handlePILOT(value);
        if (id == fg1000.FASCIA.COM1 ) return controller.handleCOM1(value);
        if (id == fg1000.FASCIA.COM2 ) return controller.handleCOM2(value);
        if (id == fg1000.FASCIA.COM3 ) return controller.handleCOM3(value);
        if (id == fg1000.FASCIA.TEL ) return controller.handleTEL(value);
        if (id == fg1000.FASCIA.SPKR ) return controller.handleSPKR(value);
        if (id == fg1000.FASCIA.HISENS ) return controller.handleHISENS(value);
        if (id == fg1000.FASCIA.NAV1 ) return controller.handleNAV1(value);
        if (id == fg1000.FASCIA.NAV2 ) return controller.handleNAV2(value);
        if (id == fg1000.FASCIA.PLAY ) return controller.handlePLAY(value);
        if (id == fg1000.FASCIA.COPLT ) return controller.handleCOPLT(value);
      }

      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
  }

  me._transmitter.Register(me._recipient);
  me._registered = 1;
},

DeRegisterWithEmesary : func()
{
  # remove registration from transmitter; but keep the recipient once it is created.
  if (me._registered == 1) me._transmitter.DeRegister(me._recipient);
  me._registered = 0;
},

start : func() {
  me.RegisterWithEmesary();
},
stop : func() {
  me.DeRegisterWithEmesary();
},

};
