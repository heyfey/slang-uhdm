// r10v152 arm C — HOMES.  The same out-of-body constructor shape written in a
// package, in $unit, in a module, in a program and in an interface, plus an
// IN-BODY paren-less constructor.  Golden decides each independently.
class UnitK; int uk; endclass

class UnitHost;                     // $unit scope
  int uh;
  extern function new();
endclass
function UnitHost::new();
  UnitK u_eaten;                    // h01
  UnitK u_plain;                    // h02
  u_eaten = null;
  u_plain = null;
  uh = 1;
endfunction

package homepkg;
  class PkgK; int pk; endclass
  class PkgHost;
    int ph;
    extern function new();
  endclass
  function PkgHost::new();
    PkgK p_eaten;                   // h03  THE LAW
    PkgK p_plain;                   // h04
    p_eaten = null;
    p_plain = null;
    ph = 2;
  endfunction

  class InbodyBare;                 // IN-BODY, PAREN-LESS constructor
    int ib;
    function new;
      PkgK ib_eaten;                // h05
      PkgK ib_plain;                // h06
      ib_eaten = null;
      ib_plain = null;
      ib = 3;
    endfunction
  endclass

  PkgK ib_eaten;                    // package var colliding with h05
  PkgK ib_plain;                    // package var colliding with h06
endpackage

module modhome;
  class ModK; int mk; endclass
  class ModHost;
    int mh;
    extern function new();
  endclass
  function ModHost::new();
    ModK m_eaten;                   // h07
    ModK m_plain;                   // h08
    m_eaten = null;
    m_plain = null;
    mh = 4;
  endfunction
  ModHost mhv;
  initial mhv = new();
endmodule

program proghome;
  class ProgK; int gk; endclass
  class ProgHost;
    int gh;
    extern function new();
  endclass
  function ProgHost::new();
    ProgK g_eaten;                  // h09
    ProgK g_plain;                  // h10
    g_eaten = null;
    g_plain = null;
    gh = 5;
  endfunction
  ProgHost ghv;
  initial ghv = new();
endprogram

interface ifhome;
  class IfK; int ik; endclass
  class IfHost;
    int ih;
    extern function new();
  endclass
  function IfHost::new();
    IfK i_eaten;                    // h11
    IfK i_plain;                    // h12
    i_eaten = null;
    i_plain = null;
    ih = 6;
  endfunction
  IfHost ihv;
  initial ihv = new();
endinterface

module tophome;
  import homepkg::*;
  UnitHost uhv; PkgHost phv; InbodyBare ibv;
  ifhome ifi();
  proghome pgi();
  initial begin
    uhv = new(); phv = new(); ibv = new();
  end
endmodule
