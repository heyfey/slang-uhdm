// r10uvm214 grid arm H — THE `$unit` CONJUNCT, THE LAW'S OTHER HALF.
// The same package and the same out-of-body class-method reads as arm A, with
// ONE addition: a COMPILATION-UNIT-scope `import ph214u::*;`.  That import
// HOISTS the package's parameters into the DESIGN's own parameter list, and
// Surelog's `UhdmWriter::lateBinding` walks a reference's PARENT CHAIN — whose
// last step is `uhdmdesign`, matched against `d->Parameters()` BY NAME
// (UhdmWriter.cpp:3358-3372) — BEFORE it ever reaches the
// `m->Param_assigns()` branch this pass's law transcribes.  So in a design
// written this way the def listing's own reference binds the DESIGN-LEVEL
// PARAMETER OBJECT, not the listing's Rhs, and this law must stand down.
//
// This is the shape of `SimpleUVM` (`import uvm_pkg::*;` on line 1 of
// testbench.sv) and of `Scoreboard` (`import svunit_pkg::*;` on line 2) — where
// `SeqDriver` puts its imports inside `package adpcm_pkg` and inside
// `module top_tb` and therefore takes the Rhs.
import ph214u::*;

package ph214u;

  parameter int ua214 = 21;
  parameter ub214 = ua214;
  parameter uc214 = ua214 + 3;

  function automatic int usink214(int a, int b);
    return a + b;
  endfunction

  class U214H;
    extern function int u_arg214();
    extern function int u_ret214();
  endclass

  function int U214H::u_arg214();
    return usink214(ua214, ub214);
  endfunction

  function int U214H::u_ret214();
    return uc214;
  endfunction

endpackage

module toph214;
  ph214u::U214H u = new();
  int x;
  initial x = u.u_arg214();
endmodule
