// r10uvm217 grid arm A — THE LAW: HOP DEPTH.
// A module materialises the listing of the package it imports, and that
// listing already carries the clone of everything THAT package wildcard-
// imports, to any depth.  Cells: a one-hop control, a two-, three- and
// four-package chain, and a module that imports both ends of a chain.
package pa0;
  int a0_own0;
  string a0_own1;
endpackage

package pa1;
  int a1_pre;
  import pa0::*;
  int a1_post;
endpackage

package pa2;
  import pa1::*;
  int a2_own;
endpackage

package pa3;
  int a3_own;
  import pa2::*;
endpackage

module ga_h1;
  import pa0::*;
  logic ga_h1_clk;
endmodule

module ga_h2;
  import pa1::*;
  logic ga_h2_clk;
endmodule

module ga_h3;
  import pa2::*;
  logic ga_h3_clk;
endmodule

module ga_h4;
  import pa3::*;
  logic ga_h4_clk;
endmodule

module ga_both;
  import pa0::*;
  import pa1::*;
  logic ga_both_clk;
endmodule
