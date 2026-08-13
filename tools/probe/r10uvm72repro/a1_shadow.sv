// r10uvm72 arm a1 — THE SHADOW AXIS, UVM-free.
//
// uvm-1.2 declares `uvm_report_enabled` THREE times: once as a PACKAGE FREE
// FUNCTION (uvm_globals.svh:133 — the cmp head) and twice as a CLASS METHOD
// (uvm_report_object.svh:120, uvm_sequence_item.svh:343).  Inside a method of a
// class that INHERITS one of those methods, the unqualified call name is
// SHADOWED: slang resolves it to the inherited METHOD, Surelog binds the
// PACKAGE FUNCTION.  This arm reproduces exactly that, with no UVM.
//
// Every cell is one call to `fe`, and the axes are:
//   * does the CALLER's class inherit a method named `fe`?  (shadowed / clear)
//   * is the caller method IN-BODY or OUT-OF-BODY (`extern`)?
//   * is the call QUALIFIED (`p1::fe`) or bare?
//   * the caller is a class method / a package free function / a module
//     procedure — the three caller contexts the brief names.
package p1;

  // the PACKAGE FREE FUNCTION — the shadowed callee, the head's analogue
  function int fe(int v);
    return v + 100;
  endfunction

  function int other_free(int v);        // a free function nothing shadows
    return v + 7;
  endfunction

  // ---- the SHADOWING base: a class method of the SAME NAME
  class shbase;
    function int fe(int v);              // shadows p1::fe for every derived
      return v + 1;
    endfunction
    function void base_inbody();
      if (fe(1)) $display("base_inbody");        // caller class == callee class
    endfunction
  endclass

  // ---- SHADOWED derived class: `fe` resolves to shbase::fe by inheritance
  class shderived extends shbase;
    function void d_inbody();
      if (fe(2)) $display("d_inbody");           // SHADOWED, in-body
    endfunction
    function void d_inbody_qual();
      if (p1::fe(3)) $display("d_inbody_qual");  // SHADOWED but QUALIFIED
    endfunction
    function void d_inbody_other();
      if (other_free(4)) $display("d_inbody_other");  // unshadowed name
    endfunction
    extern function void d_oob();
    extern function void d_oob_qual();
  endclass

  function void shderived::d_oob();
    if (fe(5)) $display("d_oob");                // SHADOWED, OUT-OF-BODY
  endfunction

  function void shderived::d_oob_qual();
    if (p1::fe(6)) $display("d_oob_qual");       // SHADOWED, oob, QUALIFIED
  endfunction

  // ---- a SECOND level of derivation (uvm_reg_sequence's shape)
  class shgrand extends shderived;
    function void g_inbody();
      if (fe(7)) $display("g_inbody");           // shadowed two levels up
    endfunction
    extern function void g_oob();
  endclass

  function void shgrand::g_oob();
    if (fe(8)) $display("g_oob");
  endfunction

  // ---- CLEAR class: nothing named `fe` is inherited
  class clear;
    function void c_inbody();
      if (fe(9)) $display("c_inbody");           // resolves to p1::fe directly
    endfunction
    extern function void c_oob();
  endclass

  function void clear::c_oob();
    if (fe(10)) $display("c_oob");
  endfunction

  // ---- caller context: another PACKAGE FREE FUNCTION
  function void pkg_caller();
    if (fe(11)) $display("pkg_caller");
  endfunction

endpackage

// ---- caller context: a MODULE procedure, wildcard-imported
module top;
  import p1::*;
  shderived sd;
  clear cl;
  initial begin
    if (fe(12)) $display("mod_wildcard");        // wildcard-imported bare call
    if (p1::fe(13)) $display("mod_qualified");   // qualified from a module
    sd = new();
    sd.d_inbody();
    cl = new();
    cl.c_inbody();
    p1::pkg_caller();
  end
endmodule
