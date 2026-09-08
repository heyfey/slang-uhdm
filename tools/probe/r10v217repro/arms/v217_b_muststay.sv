// v217 arm B — WHAT MUST NOT MOVE. A leaf package with no imports at all,
// a module importing only that leaf, a package nobody imports, and a module
// with no import at all.
package pb0;
  int b0_v;
  string b0_s;
endpackage

package pb_orphan;
  int b_orphan_v;
endpackage

module vb_leaf;
  import pb0::*;
  logic vb_leaf_clk;
endmodule

module vb_none;
  logic vb_none_clk;
  int   vb_none_i;
endmodule
