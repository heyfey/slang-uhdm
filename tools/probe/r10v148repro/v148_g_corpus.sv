// r10v148 arm G — THE CORPUS SHAPE, MINIMISED: an out-of-body PAREN-LESS
// method of a package class (TF-ITEM), body locals shadowing package variables,
// an `if` predicate at BODY TOP LEVEL beside the SAME name's `if` predicate
// nested inside a `foreach` (the split uvm_component.svh proves at 3432:14 vs
// 3410:48), a method-call RECEIVER and a hier_path element on the same names,
// and a module that imports the package.  MEASUREMENT ONLY.
package v7_pkg;
  class root_v7;
    int    depth_v7;
    function int get_depth; return depth_v7; endfunction
  endclass

  class svc_v7;
    static function root_v7 get_root;
      root_v7 r;
      r = new();
      return r;
    endfunction
  endclass

  root_v7 apex_v7;
  svc_v7  serv_v7;
  int     names_v7 [3];

  class comp_v7;
    extern function void set_verb_v7;
  endclass

  function void comp_v7::set_verb_v7;
    root_v7 apex_v7;
    svc_v7  serv_v7;
    int     names_v7 [3];
    int     hold_v7;
    serv_v7 = svc_v7::get_root() != null ? null : null;   // LVALUE
    apex_v7 = serv_v7 == null ? null : null;              // LVALUE + READ
    hold_v7 = apex_v7.get_depth();                        // RECV (hier_path)
    if (apex_v7 != null) hold_v7 = 1;                     // BODY-TOP-LEVEL if
    foreach (names_v7[i]) begin
      if (apex_v7 != null) hold_v7 = 2;                   // if nested in foreach
    end
  endfunction
endpackage

module v148_g_top;
  import v7_pkg::*;
  initial begin
    v7_pkg::comp_v7 c;
    c = new();
    c.set_verb_v7();
  end
endmodule
