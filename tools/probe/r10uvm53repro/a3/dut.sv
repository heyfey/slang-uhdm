// r10uvm53repro/a3 — THE CROSS that separates the two axes a2 left confounded.
//
// a2 showed: a CLASS PROPERTY spelled `#(...)` keeps its vpiParameter when the
// class AND the generic are at $unit scope (d1) and loses it when the class AND
// the generic are in a PACKAGE (d2/d3).  Both cells move BOTH axes at once, so
// a2 alone cannot say whether the key is
//    (A) the GENERIC CLASS's home scope, or
//    (B) the DECLARING CLASS's home scope.
//
// REFUTED CELL, recorded: the fourth corner of the 2x2 — a property in a
// PACKAGE class of a $unit generic — IS NOT LEGAL SystemVerilog.  slang rejects
// it with "cannot reference compilation unit item from within a package"
// (LRM 3.12.1), so the 2x2 can only ever be a 3-cell L.  e2 below is therefore
// THE decisive cell: $unit declaring class + PACKAGE generic.
//   e2 keeps vpiParameter  => the key is axis B (the DECLARING scope)
//   e2 loses vpiParameter  => the key is axis A (the GENERIC's home)
//
// It also adds the two containers a2 never tried: a class declared inside a
// MODULE, and a package class of ANOTHER package's generic.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

class ucfg53;
  int q;
endclass

class ugc53 #(type T = int);
  T t;
endclass

package s53;
  class scfg53;
    int q;
  endclass
  class sgc53 #(type T = int);
    T t;
  endclass
endpackage

package r53;
  class rcfg53;
    int q;
  endclass
  class rgc53 #(type T = int);
    T t;
  endclass

  // e3_pkgclass_pkggeneric: the control — declaring class and generic both in
  // THIS package (a2's d2 cell, the corpus-head shape).
  class e3_holder;
    rgc53#(rcfg53) e3_pkgclass_pkggeneric;
  endclass

  // e6_pkgclass_otherpkggeneric: declaring class in r53, generic in s53.
  class e6_holder;
    s53::sgc53#(s53::scfg53) e6_pkgclass_otherpkggeneric;
  endclass
endpackage

// e2_unitclass_pkggeneric: property in a $unit class, of a PACKAGE generic.
// THE DECISIVE CELL.
class e2_holder;
  r53::rgc53#(r53::rcfg53) e2_unitclass_pkggeneric;
endclass

// e4_unitclass_unitgeneric: the control — both at $unit (a2's d1 cell).
class e4_holder;
  ugc53#(ucfg53) e4_unitclass_unitgeneric;
endclass

module top53;
  // e5_modclass_unitgeneric: property in a class declared inside a MODULE.
  class e5_holder;
    ugc53#(ucfg53) e5_modclass_unitgeneric;
  endclass
  e5_holder e5h;
  e2_holder e2h;
  e4_holder e4h;
endmodule
