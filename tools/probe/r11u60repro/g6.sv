// g6 — THE CLASS-BODY FENCE at the import-copy face (§ pkgClassBodySelectDeclined49v).
package p6;
  typedef struct { int unsigned a; int unsigned b; } u6_t;
  localparam u6_t CCLS = '{a: 4, b: 8};   // selected ONLY inside a class method
  localparam u6_t CPKG = '{a: 4, b: 8};   // selected in ordinary package code
  typedef logic [CPKG.a-1:0] c1_t;
  class c6;
    function automatic int unsigned f();
      return CCLS.a;
    endfunction
  endclass
endpackage

module g6q import p6::*; (input logic clk);
  c1_t d;
  assign d = '0;
endmodule

module g6top(input logic clk);
  g6q u_q (.clk(clk));
endmodule
