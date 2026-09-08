// v217 arm A — DIAMONDS. Root diamond (pd3 imports pd1+pd2, both import pd0)
// and a DEEP diamond (pd7 -> pd6 -> {pd4,pd5} -> pd0b).
package pd0;
  int d0_v;
  string d0_s;
endpackage

package pd1;
  import pd0::*;
  int d1_v;
endpackage

package pd2;
  import pd0::*;
  int d2_v;
endpackage

package pd3;
  import pd1::*;
  import pd2::*;
  int d3_v;
endpackage

package pd0b;
  int d0b_v;
endpackage

package pd4;
  import pd0b::*;
  int d4_v;
endpackage

package pd5;
  import pd0b::*;
  int d5_v;
endpackage

package pd6;
  import pd4::*;
  import pd5::*;
  int d6_v;
endpackage

package pd7;
  import pd6::*;
  int d7_v;
endpackage

module vd_root;
  import pd3::*;
  logic vd_root_clk;
endmodule

module vd_deep;
  import pd7::*;
  logic vd_deep_clk;
endmodule

module vd_mid;
  import pd6::*;
  logic vd_mid_clk;
endmodule
