// r10uvm113 / g113_c.sv — THE $unit-IMPORT ARM (a REFUTATION arm, and the
// residue R-unitimp113).
//
// § classOwnLateMethodBindsPkgFn113 says a class-method call whose own-class
// method is DECLARED BELOW the caller falls out to the package free function.
// g113_b proves that half.  THIS arm proves the law is not the WHOLE of what
// golden does: add a COMPILATION-UNIT import that brings the same name into
// $unit — a wildcard `import homec::*;` OR the explicit `import homec::rho;` —
// and golden falls out to the package function for BOTH callers, the one
// written above the class's own `rho` AND the one written below it.
//
// Measured, golden, `below`'s callee:
//   no $unit import      -> class_defn:Cinc::rho      (g113_b's rule)
//   import homec::*;     -> package:homec::rho
//   import homec::rho;   -> package:homec::rho
//   import otherc::*;    -> class_defn:Cinc::rho     (a DIFFERENT package's
//                                                     import does nothing)
//
// We bind `Cinc::rho` there, pristine AND patched — this pass moves the `above`
// cell TO GOLDEN and leaves the `below` cell exactly where it was, so the arm
// is a MISS and never an AWAY.  The mechanism behind the flip is not decoded.
package otherc;
  function int zeta(int x); return x; endfunction
endpackage
package homec;
  function int rho(int x); return x + 1; endfunction
  class Cinc;
    function int above(); return rho(1); endfunction
    function int rho(int x); return x + 100; endfunction
    function int below(); return rho(2); endfunction
  endclass
endpackage
import homec::rho;
module tb_c;
  import homec::*;
  Cinc c;
  initial c = new();
endmodule
