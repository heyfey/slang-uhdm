// r10v172 arm 4 — HOMES and MULTIPLICITY.  The same collapse face written in
// nine different homes, with the module instantiated ONE, TWO and THREE times
// so the elaborated copies are exercised, plus the two negatives the law's
// fences rest on (an INHERITED base method, an OUT-OF-BODY definition) written
// in name orders and spellings the implementer's own arms do not use.
// MEASUREMENT ONLY.
package pv4172;
  function int alpha172(); return 1; endfunction   // a package free FUNCTION
  task     Beta172();     endtask                  // a package free TASK, mixed case
  function int gamma9172(); return 9; endfunction  // a digit-bearing spelling

  class Bag4172;
    string q172[$];
    int    n172;
  endclass

  // the INHERITED negative, written base-first
  class Root4172;
    function void common172(); endfunction
    function void rootonly172(); endfunction
  endclass

  class Leaf4172 extends Root4172;
    function void ownfn172(); endfunction
    function void probe4172();
      Bag4172 common172;      // v4_01 INHERITED name  -> must NOT collapse
      Bag4172 rootonly172;    // v4_02 INHERITED name  -> must NOT collapse
      Bag4172 ownfn172;       // v4_03 the class's OWN method -> COLLAPSE
      Bag4172 alpha172;       // v4_04 imported package function -> COLLAPSE
      Bag4172 Beta172;        // v4_05 imported package TASK -> COLLAPSE (task_call)
      Bag4172 gamma9172;      // v4_06 digit-bearing spelling -> COLLAPSE
      common172   = new(); common172.q172.push_back("v4_01");
      rootonly172 = new(); rootonly172.q172.push_back("v4_02");
      ownfn172    = new(); ownfn172.q172.push_back("v4_03");
      alpha172    = new(); alpha172.q172.push_back("v4_04");
      Beta172     = new(); Beta172.q172.push_back("v4_05");
      gamma9172   = new(); gamma9172.q172.push_back("v4_06");
    endfunction

    // v4_07 a CONSTRUCTOR body
    function new();
      Bag4172 ownfn172;
      ownfn172 = new(); ownfn172.q172.push_back("v4_07");
    endfunction

    // v4_08 a STATIC method body
    static function void sprobe172();
      Bag4172 alpha172;
      alpha172 = new(); alpha172.q172.push_back("v4_08");
    endfunction

    // v4_09 an EXTERN-declared method, defined out of body below
    extern function void eprobe172();

    // v4_10 a name that is an extern PROTOTYPE of this class
    function void protoprobe172();
      Bag4172 eprobe172;
      eprobe172 = new(); eprobe172.q172.push_back("v4_10");
    endfunction
  endclass

  // v4_09 — the OUT-OF-BODY body.  Surelog compiles it in the PACKAGE scope.
  function void Leaf4172::eprobe172();
    Bag4172 ownfn172;      // a CLASS method name, seen from an out-of-body body
    Bag4172 alpha172;      // a PACKAGE function name, seen from an out-of-body body
    ownfn172 = new(); ownfn172.q172.push_back("v4_09a");
    alpha172 = new(); alpha172.q172.push_back("v4_09b");
  endfunction

  // v4_11 — a NESTED class reading the OUTER class's method name
  class Outer4172;
    function void outfn172(); endfunction
    class Inner4172;
      function void iprobe172();
        Bag4172 outfn172;
        Bag4172 alpha172;
        outfn172 = new(); outfn172.q172.push_back("v4_11");
        alpha172 = new(); alpha172.q172.push_back("v4_12");
      endfunction
    endclass
  endclass
endpackage

interface ifv4172;
  import pv4172::*;
  function int ifn172(); return 1; endfunction
  // v4_13 an INTERFACE task home
  task iftask172();
    Bag4172 ifn172;
    Bag4172 alpha172;
    ifn172   = new(); ifn172.q172.push_back("v4_13");
    alpha172 = new(); alpha172.q172.push_back("v4_14");
  endtask
endinterface

program pgv4172;
  import pv4172::*;
  function int pfn172(); return 1; endfunction
  // v4_15 a PROGRAM function home
  function void pprobe172();
    Bag4172 pfn172;
    pfn172 = new(); pfn172.q172.push_back("v4_15");
  endfunction
  initial pprobe172();
endprogram

module leafv4172;
  import pv4172::*;
  function int mfn172(); return 1; endfunction

  // v4_16/v4_17 — a module function home, elaborated once per INSTANCE
  function void mprobe172();
    Bag4172 mfn172;
    Bag4172 alpha172;
    mfn172   = new(); mfn172.q172.push_back("v4_16");
    alpha172 = new(); alpha172.q172.push_back("v4_17");
  endfunction

  // v4_18 — inside a GENERATE block's function
  for (genvar gi = 0; gi < 2; gi++) begin : gblk172
    function void gprobe172();
      Bag4172 mfn172;
      mfn172 = new(); mfn172.q172.push_back("v4_18");
    endfunction
  end

  initial mprobe172();
endmodule

module topv4172;
  import pv4172::*;
  ifv4172   iv172();
  leafv4172 i1172();          // ONE
  leafv4172 i2172();          // TWO
  leafv4172 i3172();          // THREE
  pv4172::Leaf4172 lf172;
  pv4172::Outer4172::Inner4172 in172;
  initial begin
    lf172 = new(); lf172.probe4172(); lf172.eprobe172(); lf172.protoprobe172();
    pv4172::Leaf4172::sprobe172();
    in172 = new(); in172.iprobe172();
    iv172.iftask172();
  end
endmodule
