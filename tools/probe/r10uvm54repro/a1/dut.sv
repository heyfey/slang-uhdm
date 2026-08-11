// r10uvm54repro/a1 — the CLASS-NESTED class-handle typedef GROUP with NO
// package-level anchor: WHICH member is the BASE?
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  Read with
//   gold.sh a1 <outdir> <bin>   then   tdgroup.py <dump> groups
//
// Every cell name below is a TYPEDEF name in this file, so a cell is a
// measurement and not a description.  Three candidate base-pick keys are made
// to DISAGREE on purpose:
//
//   K1 the DECLARING CLASS's Surelog design-map name  (`<pkg>::<cls>` /
//      `work@<cls>`)                                  -- the candidate law
//   K2 the TYPEDEF's own name                         -- pass-49/50's law for
//                                                        PACKAGE-level groups
//   K3 SOURCE ORDER
//
// GROUP g54 (no anchor): b_owner54 is declared FIRST and its typedef name
// sorts FIRST; a_owner54 is declared SECOND and its typedef name sorts LAST.
//   K1 predicts base = r54::a_owner54::td_zzz54
//   K2 predicts base = r54::b_owner54::td_aaa54
//   K3 predicts base = r54::b_owner54::td_aaa54
//
// GROUP m54 (no anchor, BOTH members in ONE class): the two typedefs sit in
// the same class, so K1 cannot separate them and only the within-class order
// (Surelog's per-class TypeDefMap is a std::map by TYPEDEF NAME) can.
//   prediction: base = r54::c_owner54::t_aaa54, the name-first of the two,
//   even though t_bbb54 is declared FIRST.
//
// GROUP h54: exactly ONE class-nested member and no anchor -> golden must give
// it NO vpiTypedefAlias at all (this is the cell that stops the law from
// aliasing a singleton to itself).
//
// GROUP k54: a PACKAGE-level typedef of the generic EXISTS (`k_anchor54`), so
// this is pass-50 law 4's shape and the base must be the PACKAGE object, NOT
// any class-nested one.  It is the control that the new law must not disturb.
//
// GROUP n54: the SPELLING of K1.  Owners are `raa54::zz54`, `zbb54::aa54` and
// `work@mm54`.
//   FULL-NAME order  : raa54::zz54 < work@mm54 < zbb54::aa54  -> base zz54
//   SHORT-NAME order : aa54 < mm54 < zz54                     -> base aa54
// This is the cell that decides whether the key carries the package prefix.

package s54;
  class gcfg54;
    int x;
  endclass
  class g54 #(type T = int);
    T y;
  endclass
  class h54 #(type T = int);
    T z;
  endclass
  class k54 #(type T = int);
    T w;
  endclass
  class m54 #(type T = int);
    T v;
  endclass
  class n54 #(type T = int);
    T u;
  endclass
  // THE PACKAGE ANCHOR of group k54 (and of nothing else).
  typedef k54#(int) k_anchor54;
endpackage

package r54;
  import s54::*;

  // SOURCE-FIRST owner, but its name sorts SECOND.
  class b_owner54;
    typedef g54#(int) td_aaa54;      // typedef name sorts FIRST
    typedef k54#(int) ka_bbb54;      // group k54: anchored
  endclass

  // SOURCE-SECOND owner, but its name sorts FIRST.
  class a_owner54;
    typedef g54#(byte) td_zzz54;     // typedef name sorts LAST
    typedef h54#(int)  h_only54;     // group h54: the ONLY member
  endclass

  // Both m54 members in ONE class: the within-class tiebreak.
  class c_owner54;
    typedef m54#(int)      t_bbb54;  // declared FIRST
    typedef m54#(shortint) t_aaa54;  // name sorts FIRST
  endclass
endpackage

package raa54;
  import s54::*;
  class zz54;
    typedef n54#(int) n_r54;
  endclass
endpackage

package zbb54;
  import s54::*;
  class aa54;
    typedef n54#(byte) n_z54;
  endclass
endpackage

// A $unit (compilation-unit) class: Surelog registers it as `work@mm54`.
class mm54;
  typedef s54::n54#(shortint) n_u54;
endclass

module a1_top54;
  s54::gcfg54           cfg54;
  r54::b_owner54        b54;
  r54::a_owner54        a54;
  r54::c_owner54        c54;
  raa54::zz54           z54;
  zbb54::aa54           y54;
  mm54                  m0_54;
  s54::k_anchor54       ka54;
  initial begin
    cfg54 = new;
    b54 = new;
    a54 = new;
    c54 = new;
    z54 = new;
    y54 = new;
    m0_54 = new;
    ka54 = new;
  end
endmodule
