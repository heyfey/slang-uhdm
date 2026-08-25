// r10uvm140 arm B — WHERE THE FUNCTION LIVES.  Same law, seven homes:
// package-scope function, in-body package-class method, OUT-OF-BODY package
// class method (the uvm_sequencer_base::get_arbitration shape), module-scope
// function, module-class in-body method, $unit-scope function, $unit-class
// method.  Every home also carries a BASE-returning twin as its control.
typedef enum { Dawn = 1, Noon = 5, Dusk = 9 } dayPhase;
typedef dayPhase  DayPhase_e;          // the alias, at $unit
typedef struct packed { logic [2:0] hh; logic [5:0] mm; } clockRec;
typedef clockRec  ClockRec_s;

function DayPhase_e unitPhaseAlias(); return Noon; endfunction
function dayPhase   unitPhaseBase();  return Dawn; endfunction
function ClockRec_s unitClockAlias(); ClockRec_s r; return r; endfunction

class UnitTimer;
  function DayPhase_e whenAlias(); return Dusk; endfunction
  function dayPhase   whenBase();  return Dawn; endfunction
endclass

package Harbour_pkg;
  typedef enum { Ebb = 2, Slack = 4, Flood = 6 } tideMode;
  typedef tideMode  TideMode_e;
  typedef tideMode  tide_mode_t;       // a SECOND alias of the same base
  typedef struct packed { logic [7:0] depth; } soundingRec;
  typedef soundingRec Sounding_s;

  function TideMode_e pkgTideAlias();  return Flood; endfunction
  function tideMode   pkgTideBase();   return Ebb;   endfunction
  function Sounding_s pkgSoundAlias(); Sounding_s r; return r; endfunction

  class Berth;
    function tide_mode_t inBodyAlias(); return Slack; endfunction
    function tideMode    inBodyBase();  return Ebb;   endfunction
    extern function TideMode_e outOfBodyAlias();
    extern function tideMode   outOfBodyBase();
    extern function Sounding_s outOfBodySound();
  endclass

  function TideMode_e Berth::outOfBodyAlias(); return Flood;  endfunction
  function tideMode   Berth::outOfBodyBase();  return Slack;  endfunction
  function Sounding_s Berth::outOfBodySound(); Sounding_s r; return r; endfunction
endpackage

module Quay;
  import Harbour_pkg::*;
  typedef enum { Idle3 = 0, Busy3 = 7 } berthState;
  typedef berthState BerthState_e;

  function BerthState_e modStateAlias(); return Busy3; endfunction
  function berthState   modStateBase();  return Idle3; endfunction

  class Crane;
    function BerthState_e liftAlias(); return Busy3; endfunction
    function berthState   liftBase();  return Idle3; endfunction
  endclass

  Berth b1;
  Crane k1;
  UnitTimer t1;
  BerthState_e st;
  TideMode_e   td;
  DayPhase_e   dp;
  initial begin
    b1 = new(); k1 = new(); t1 = new();
    st = modStateAlias();
    td = b1.outOfBodyAlias();
    dp = t1.whenAlias();
  end
endmodule
