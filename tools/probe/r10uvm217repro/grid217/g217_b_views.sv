// r10uvm217 grid arm B — THE VIEW AND MULTIPLICITY CONJUNCT.
// A COMPILATION-UNIT-scope import copies the listing TWICE and a module-scope
// one ONCE (§ collectMaterializedPkgs); the transitive clone must ride each
// copy, in both the def and the elaborated view.
package pb0;
  int b0_v;
  string b0_s;
endpackage

package pb1;
  import pb0::*;
  int b1_v;
endpackage

import pb1::*;

module gb_file;
  logic gb_file_clk;
endmodule

module gb_both;
  import pb1::*;
  logic gb_both_clk;
endmodule

module gb_mixed;
  import pb0::*;
  logic gb_mixed_clk;
endmodule
