// r10uvm97 arm a2 — NEGATIVE / FENCE.  MEASUREMENT-ONLY golden arm.
//
// A GENUINE class-nested typedef group: several DISTINCT classes each typedef
// the SAME target class.  Golden resolves it into one base plus aliased clones
// (§ classNestedClassTdGroupNoAnchor54, pass 54).  Nothing here may move: the
// members differ in their DECLARING CLASS, so the pass-97 dedup — which is
// keyed on (declaring GENERIC class, typedef name) — cannot see them as one.
package q97b;

  class tgt97b;
    int v;
  endclass

  class other97b;
    int w;
  endclass

  class aa97b;
    typedef tgt97b n_a97b;      // group member 1 (base: owner sorts first)
    n_a97b h_a;
  endclass

  class bb97b;
    typedef tgt97b n_b97b;      // group member 2 -> aliased clone
    n_b97b h_b;
  endclass

  class cc97b;
    typedef tgt97b n_c97b;      // group member 3 -> aliased clone
    n_c97b h_c;
  endclass

  class dd97b;
    typedef other97b n_d97b;    // a ONE-member group: no alias in golden
    n_d97b h_d;
  endclass

endpackage

module top97b;
endmodule
