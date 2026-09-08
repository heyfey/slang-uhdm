// v217 arm C — CONTESTED NAMES ACROSS THE TRANSITIVE HOP (uvm206's ambiguity).
// pc1 and pc2 both declare `shared_v`; pc3 imports both; a module imports pc3.
// pc4 declares a name its transitive import also declares (shadowing).
package pc1;
  int shared_v;
  int c1_only;
endpackage

package pc2;
  int shared_v;
  int c2_only;
endpackage

package pc3;
  import pc1::*;
  import pc2::*;
  int c3_v;
endpackage

package pc4;
  import pc1::*;
  int shared_v;
  int c4_v;
endpackage

module vc_both;
  import pc3::*;
  logic vc_both_clk;
endmodule

module vc_shadow;
  import pc4::*;
  logic vc_shadow_clk;
endmodule
