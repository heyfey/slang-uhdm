// r10v107 arm b9 — WHICH NAMES SUPPRESS THE MINT.  MEASUREMENT ONLY.
// Surelog's module-level search (UhdmWriter.cpp, the tail of lateBinding) looks
// at nets, variables, param_assigns, parameters, TYPESPECS and file typedef
// enums before it mints.  This arm varies ONLY the NAME of the `ref_var` local
// in the one shape § oobRefVarLocalHoistNet107 moves, and reads golden's answer.
package pb9;

  typedef int      td_pkg9;        // a package TYPEDEF
  typedef struct packed { logic a; } ts_pkg9;
  parameter int    pm_pkg9 = 3;    // a package PARAMETER
  typedef enum { EA9, EB9 } en_pkg9;

  class d9;
    int fld;
  endclass

  class cls_nm9;                   // a package CLASS name
    int z;
  endclass

  class snk9;
    function int ask(d9 v); return 0; endfunction
  endclass

  function int fn_pkg9(int a); return a; endfunction   // a package FUNCTION

  class c9 #(type T = d9);
    snk9 s;
    int  prop9;                    // a CLASS PROPERTY name
    extern function void n_plain();     // a name nothing else spells
    extern function void n_typedef();   // == a package typedef
    extern function void n_struct();    // == a package struct typedef
    extern function void n_param();     // == a package parameter
    extern function void n_enumtd();    // == a package enum typedef
    extern function void n_class();     // == a package class
    extern function void n_func();      // == a package function
    extern function void n_prop();      // == a class property
    extern function void n_modnet();    // == a NET declared in the importing module
    extern function void n_modvar();    // == a VARIABLE declared in the module
  endclass

  function void c9::n_plain();    T uniq9;    if (s.ask(uniq9)   == 0) begin end endfunction
  function void c9::n_typedef();  T td_pkg9;  if (s.ask(td_pkg9) == 0) begin end endfunction
  function void c9::n_struct();   T ts_pkg9;  if (s.ask(ts_pkg9) == 0) begin end endfunction
  function void c9::n_param();    T pm_pkg9;  if (s.ask(pm_pkg9) == 0) begin end endfunction
  function void c9::n_enumtd();   T en_pkg9;  if (s.ask(en_pkg9) == 0) begin end endfunction
  function void c9::n_class();    T cls_nm9;  if (s.ask(cls_nm9) == 0) begin end endfunction
  function void c9::n_func();     T fn_pkg9;  if (s.ask(fn_pkg9) == 0) begin end endfunction
  function void c9::n_prop();     T prop9;    if (s.ask(prop9)   == 0) begin end endfunction
  function void c9::n_modnet();   T mnet9;    if (s.ask(mnet9)   == 0) begin end endfunction
  function void c9::n_modvar();   T mvar9;    if (s.ask(mvar9)   == 0) begin end endfunction

endpackage

module topb9;
  import pb9::*;
  wire  mnet9;                     // the module NET the local's name collides with
  logic mvar9;                     // the module VARIABLE
  c9 #(d9) inst;
  initial inst = new();
endmodule
