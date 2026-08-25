// r10v127 VERIFIER grid D — HOMES beyond the pass's own grid: a module TASK, an
// INTERFACE, a PROGRAM, a class NESTED in a class, a class EXTENDING one from a
// different package, and the package positive control.  Only a PACKAGE-level
// declaration is compiled with Reduce::Yes.  MEASUREMENT ONLY.
package Bittern;
  import "DPI-C" function int btProbe(int mote);
  class Cresset;
    extern function int ctrl(int mote);
  endclass
  function int Cresset::ctrl(int mote);
    return btProbe(mote);                       // POSITIVE control (stamped)
  endfunction
endpackage

package Fenland;
  import "DPI-C" function int fnProbe(int mote);
  // a class DERIVED from another package's class, defined out of body
  class Sedge extends Bittern::Cresset;
    extern function int derived(int mote);
  endclass
  function int Sedge::derived(int mote);
    return fnProbe(mote);                       // stamped (package home)
  endfunction

  // a class holding a nested class, the OUTER method defined out of body
  class Outerly;
    class Innerly;
      int deepSeed = 8;
    endclass
    extern function int shallow(int mote);
  endclass
  function int Outerly::shallow(int mote);
    return fnProbe(mote);                       // stamped (package home)
  endfunction

  // a package TASK with an out-of-body class TASK alongside
  task automatic fenTask(int mote);
    int keep;
    keep = fnProbe(mote);
  endtask
endpackage

interface Girdle_if;
  import "DPI-C" function int giProbe(int mote);
  function automatic int ifCaller(int mote);
    return giProbe(mote);                       // bare (interface home)
  endfunction
  class Coping;
    extern function int ifOob(int mote);
  endclass
  function int Coping::ifOob(int mote);
    return giProbe(mote);                       // bare (interface home)
  endfunction
endinterface

module Marlin_home;
  import "DPI-C" function int mlProbe(int mote);
  task automatic modTask(int mote);
    int keep;
    keep = mlProbe(mote);                       // bare (module task)
  endtask
  class Ratchet;
    extern task modOobTask(int mote);
  endclass
  task Ratchet::modOobTask(int mote);
    int keep;
    keep = mlProbe(mote);                       // bare (module home)
  endtask
  int got;
  initial got = mlProbe(3);
endmodule

program Tiller_prog;
  import "DPI-C" function int tpProbe(int mote);
  function automatic int progCaller(int mote);
    return tpProbe(mote);                       // bare (program home)
  endfunction
  class Coulter;
    extern function int progOob(int mote);
  endclass
  function int Coulter::progOob(int mote);
    return tpProbe(mote);                       // bare (program home)
  endfunction
  initial begin end
endprogram

module Bittern_top;
  import Bittern::*;
  import Fenland::*;
  Cresset cr;
  Sedge   sd;
  int got;
  initial begin
    cr = new(); sd = new();
    got = cr.ctrl(1) + sd.derived(2);
  end
endmodule
