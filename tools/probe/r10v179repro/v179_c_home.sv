// r10v179 ADVERSARIAL ARM C — HOMES.  The listing axis the patch's second
// conjunct (`pkgDefViewBody9`) actually names, plus every home the predicate
// must NOT reach.  MEASUREMENT ONLY.
//
// r10uvm179's arm D tested a package FREE FUNCTION with a RESOLVABLE local
// only, which cannot fire the predicate at all (gate (1) needs a `ref_var`).
// Here the free function's local IS unresolved (a `virtual interface` handle
// and a forward-declared class), which is the untested half.
interface probe_if_w;
  logic strobe;
  function automatic int sniff_w(int v); return v; endfunction
endinterface

package pkg_xray;

  typedef class Later;          // forward declaration: unresolved at def time

  class Gadget;
    int nibble;
  endclass

  class Bench;
    function int  hit(Gadget g); return 0; endfunction
    function int  hitl(Later l); return 0; endfunction
    function int  hitv(int v); return v; endfunction
    function void shove(Gadget g); endfunction
  endclass

  class Later;
    int hue;
  endclass

  class Cabinet #(type SLOT = Gadget);
    Bench bn;
    int   ticker;
    // IN-BODY method: § classInBodyRecvCallArgNoBind52's home.
    function void inbody_face();
      SLOT here;
      if (bn.hit(here) == 0) ticker = 1;                 // w01 in-body
    endfunction
    extern function void oob_func_face();                // w02 oob FUNCTION
    extern task          oob_task_face();                // w03 oob TASK
  endclass

  function void Cabinet::oob_func_face();
    SLOT here;
    if (bn.hit(here) == 0) ticker = 2;                   // w02
  endfunction

  task Cabinet::oob_task_face();
    SLOT here;
    if (bn.hit(here) == 0) ticker = 3;                   // w03
  endtask

  // A PACKAGE FREE FUNCTION whose local is a FORWARD-DECLARED class handle —
  // the def-package listing has no resolution for it.
  Bench pkg_bench;
  int   pkg_ticker;

  function void free_face_fwd();
    Later held;
    if (pkg_bench.hitl(held) == 0) pkg_ticker = 4;       // w04 pkg free func
  endfunction

  // A PACKAGE FREE TASK, same shape.
  task free_face_task();
    Later held;
    if (pkg_bench.hitl(held) == 0) pkg_ticker = 5;       // w05 pkg free task
  endtask

  // A PACKAGE FREE FUNCTION whose local is a VIRTUAL INTERFACE handle.
  function void free_face_vif();
    virtual probe_if_w vhold;
    if (pkg_bench.hitv(vhold.sniff_w(3)) == 0) pkg_ticker = 6;  // w06
  endfunction

  // The STATEMENT twin of w04 — must stay BOUND (the statement road binds).
  function void free_stmt_fwd();
    Gadget held2;
    pkg_bench.shove(held2);                              // w07
  endfunction

endpackage

// A $unit-scope class: `pkgDefViewBody9` cannot name it (r10uvm179 residue R3).
class UnitCab;
  pkg_xray::Bench ub;
  int             utick;
  extern function void unit_face();
endclass

function void UnitCab::unit_face();
  pkg_xray::Gadget uloc;
  if (ub.hit(uloc) == 0) utick = 1;                      // w10 $unit oob
endfunction

module tb_xray;
  import pkg_xray::*;
  Cabinet #(Gadget) cab_one;
  Bench             mod_bench;
  Gadget            mod_g;
  int               mod_tick;

  // THE MODULE-FUNCTION CONTROL: a module function's local is resolvable, so
  // the predicate never fires here on either binary.
  function void mod_face();
    Gadget mloc;
    if (mod_bench.hit(mloc) == 0) mod_tick = 1;          // w20 module function
  endfunction

  // THE MODULE-PROCESS CONTROL.
  initial begin
    Gadget ploc;
    cab_one = new();
    if (mod_bench.hit(ploc) == 0) mod_tick = 2;          // w21 module process
    mod_face();
  end
endmodule

// An INTERFACE's own function.
interface iface_xray;
  pkg_xray::Bench  if_bench;
  int              if_tick;
  function void if_face();
    pkg_xray::Gadget iloc;
    if (if_bench.hit(iloc) == 0) if_tick = 1;            // w30 interface func
  endfunction
endinterface

// A PROGRAM's own function.
program prog_xray;
  pkg_xray::Bench  pr_bench;
  int              pr_tick;
  function void pr_face();
    pkg_xray::Gadget ploc2;
    if (pr_bench.hit(ploc2) == 0) pr_tick = 1;           // w40 program func
  endfunction
  initial pr_face();
endprogram
