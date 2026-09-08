// r10uvm217 grid arm E — THE SHAPES THAT COULD DOUBLE OR LOOP.
// A DIAMOND (two packages importing the same third, both imported by a
// fourth), a module importing both arms of the diamond, an EXPLICIT (single
// symbol) import in the middle of a chain, and a module that imports a
// package twice over through two different roads.
package pe0;
  int e0_v;
  string e0_s;
endpackage

package pe1;
  import pe0::*;
  int e1_v;
endpackage

package pe2;
  import pe0::*;
  int e2_v;
endpackage

package pe3;
  import pe1::*;
  import pe2::*;
  int e3_v;
endpackage

package pe4;
  import pe0::e0_v;
  int e4_v;
endpackage

module ge_diamond;
  import pe3::*;
  logic ge_diamond_clk;
endmodule

module ge_twoarms;
  import pe1::*;
  import pe2::*;
  logic ge_twoarms_clk;
endmodule

module ge_explicit;
  import pe4::*;
  logic ge_explicit_clk;
endmodule
