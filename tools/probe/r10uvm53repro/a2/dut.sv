// r10uvm53repro/a2 — THE DECIDER for law 1's gate.
//
// a1 showed golden gives NO vpiParameter and the NAME-TOKEN span to EVERY
// `#(...)` class handle when the generic class lives in a PACKAGE — class
// property, package variable and module variable alike.  ClassParamAsParam
// (CMP_EQUAL canary) shows golden DOES give vpiParameter when the same
// spelling appears with $unit classes.  a2 crosses the two candidate axes so
// the difference cannot be attributed to the wrong one:
//
//   axis A: where the GENERIC CLASS is declared   ($unit vs package)
//   axis B: `= new` initializer present or absent (ClassParamAsParam has one,
//           a1 has none)
//
// Every cell is named in a comment and read on BOTH sides.
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

// ---------------- $unit generic class ----------------
class ucfg53;
  int q;
endclass

class ugc53 #(type T = int);
  T t;
endclass

class uholder53;
  // d1_unit_prop_spec: CLASS PROPERTY of a $unit generic, no initializer
  ugc53#(ucfg53) d1_unit_prop_spec;
endclass

// ---------------- package generic class ----------------
package q53;
  class pcfg53;
    int q;
  endclass
  class pgc53 #(type T = int);
    T t;
  endclass
  class pholder53;
    // d2_pkg_prop_spec: CLASS PROPERTY of a PACKAGE generic, no initializer
    pgc53#(pcfg53) d2_pkg_prop_spec;
    // d3_pkg_prop_spec_new: same, WITH an `= new` initializer
    pgc53#(pcfg53) d3_pkg_prop_spec_new = new;
  endclass
endpackage

module top53;
  import q53::*;
  // d4_unit_modvar_new: MODULE variable of a $unit generic, WITH `= new`
  //                     — this is EXACTLY the ClassParamAsParam spelling.
  ugc53#(ucfg53) d4_unit_modvar_new = new;
  // d5_unit_modvar: MODULE variable of a $unit generic, NO initializer
  ugc53#(ucfg53) d5_unit_modvar;
  // d6_pkg_modvar_new: MODULE variable of a PACKAGE generic, WITH `= new`
  pgc53#(pcfg53) d6_pkg_modvar_new = new;
  // d7_pkg_modvar: MODULE variable of a PACKAGE generic, NO initializer
  pgc53#(pcfg53) d7_pkg_modvar;
endmodule
