// r10v140 arm Q — the HOMES.  $unit function, $unit class method, package
// function, in-body package-class method, OUT-OF-BODY package-class method,
// module function, module-class method, NESTED class, interface method.
typedef enum int { TIDE_EBB = 3, TIDE_FLOOD = 9 } tideMode;
typedef tideMode TideMode_e;
typedef struct packed { bit [5:0] depth; } tideWord;
typedef tideWord TideWord_s;

function TideMode_e unitAliasMode(); return TIDE_EBB; endfunction
function tideMode unitBaseMode(); return TIDE_FLOOD; endfunction

class Beacon;
  TideMode_e beam;
  function TideMode_e unitClsAlias(); return beam; endfunction
  function tideMode unitClsBase(); return beam; endfunction
  function TideWord_s unitClsWord(); TideWord_s w; return w; endfunction
endclass

package Harbour_pkg;
  typedef enum logic [3:0] { HARBOUR_SHUT = 2, HARBOUR_OPEN = 5 } gateState;
  typedef gateState GateState_e;
  typedef gateState gate_state_alt;
  typedef struct packed { bit [2:0] berth; bit [2:0] pier; } dockWord;
  typedef dockWord DockWord_s;

  function GateState_e pkgAliasGate(); return HARBOUR_SHUT; endfunction
  function gateState pkgBaseGate(); return HARBOUR_OPEN; endfunction

  class Wharf;
    GateState_e gate;
    function GateState_e inbodyAliasGate(); return gate; endfunction
    function gateState inbodyBaseGate(); return gate; endfunction
    extern function gate_state_alt outofbodyAltGate();
    extern function DockWord_s outofbodyWord();
    extern function gateState outofbodyBaseGate();
    class Mooring;
      function GateState_e nestedAliasGate(); return HARBOUR_OPEN; endfunction
      function DockWord_s nestedWord(); DockWord_s d; return d; endfunction
    endclass
  endclass

  function gate_state_alt Wharf::outofbodyAltGate(); return gate; endfunction
  function DockWord_s Wharf::outofbodyWord(); DockWord_s d; return d; endfunction
  function gateState Wharf::outofbodyBaseGate(); return gate; endfunction
endpackage

interface QuayIf;
  import Harbour_pkg::*;
  function automatic GateState_e ifaceAliasGate(); return HARBOUR_SHUT; endfunction
  function automatic gateState ifaceBaseGate(); return HARBOUR_OPEN; endfunction
endinterface

module harbour_top;
  import Harbour_pkg::*;
  typedef enum bit [1:0] { MAST_LOW = 1, MAST_HIGH = 2 } mastRank;
  typedef mastRank MastRank_e;
  function MastRank_e modAliasMast(); return MAST_LOW; endfunction
  function mastRank modBaseMast(); return MAST_HIGH; endfunction
  class Rigging;
    function MastRank_e clsAliasMast(); return MAST_HIGH; endfunction
    function mastRank clsBaseMast(); return MAST_LOW; endfunction
    function GateState_e clsImportedGate(); return HARBOUR_OPEN; endfunction
  endclass
  Rigging rig;
  Beacon bcn;
  QuayIf quay();
  MastRank_e mr;
  initial mr = modAliasMast();
endmodule
