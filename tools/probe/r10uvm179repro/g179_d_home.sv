// r10uvm179 arm D — THE HOMES, one golden.  MEASUREMENT ONLY.
// The SAME cell (a `ref_var` local passed to a one-name-receiver call in an
// `if` CONDITION) written in every home our emitter distinguishes, so the
// window's home terms are measured and not assumed.  The MODULE FUNCTION is
// the control the brief names: nothing in a module may move.
//
// Surelog's road here is home-BLIND — `compileComplexFuncCall` is reached from
// `compileExpression` in every home — so the expectation is that golden treats
// them alike and that our patched binary must not introduce a home split.  The
// arm is what says whether that expectation is true.
package pd179;

  class d179d;
    int fld;
  endclass

  class sink179d;
    function int  ask(d179d v); return 0; endfunction
    function void take(d179d v); endfunction
  endclass

  class c179d #(type T = d179d);
    sink179d s;
    int      w;
    // IN-BODY method of a PACKAGE class
    function void h_pkg_inbody();
      T v;
      if (s.ask(v) == 0) w = 1;                 // d01
    endfunction
    // OUT-OF-BODY method of a PACKAGE class — THE CORPUS HOME
    extern function void h_pkg_oob();
    extern task         h_pkg_oobtask();
  endclass

  function void c179d::h_pkg_oob();
    T v;
    if (s.ask(v) == 0) w = 1;                   // d02 THE CORPUS HOME
  endfunction

  task c179d::h_pkg_oobtask();
    T v;
    if (s.ask(v) == 0) w = 1;                   // d03 an out-of-body TASK
  endtask

  // A PACKAGE FREE FUNCTION.  Its local is resolvable, so this cell reads the
  // ROAD without the `ref_var` — the control that says the road alone does not
  // suppress.
  function int h_pkg_free();
    d179d v;
    sink179d sf;
    if (sf.ask(v) == 0) return 1;               // d04
    return 0;
  endfunction

endpackage

// A $unit-scope class.
class d179u;
  int fld;
endclass
class sink179u;
  function int ask(d179u v); return 0; endfunction
endclass
class c179u #(type T = d179u);
  sink179u s;
  int w;
  extern function void h_unit_oob();
endclass
function void c179u::h_unit_oob();
  T v;
  if (s.ask(v) == 0) w = 1;                     // d05 a $unit class, out-of-body
endfunction

interface if179d;
  import pd179::*;
  sink179d si;
  d179d    di;
  int      wi;
  // AN INTERFACE'S OWN FUNCTION.
  function void h_iface_fn();
    if (si.ask(di) == 0) wi = 1;                // d06
  endfunction
endinterface

module top179d;
  import pd179::*;
  c179d #(d179d) instd;
  c179u #(d179u) instu;
  if179d         theifd();
  sink179d       ms;
  d179d          md;
  int            mw;
  // A MODULE FUNCTION — THE CONTROL.
  function void h_mod_fn();
    d179d mv;
    if (ms.ask(mv) == 0) mw = 1;                // d07 MODULE FUNCTION control
  endfunction
  // A MODULE PROCESS.
  initial begin
    instd = new();
    instu = new();
    if (ms.ask(md) == 0) mw = 2;                // d08 MODULE PROCESS control
    h_mod_fn();
  end
endmodule
