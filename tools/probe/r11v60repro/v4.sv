// v4 — NESTED HOLDERS: an import copy inside a module instantiated from a
// GENERATE block, an interface instantiated inside a module, a module
// instantiated three deep, and a module instantiated ZERO times (def only).
package p4n;
  typedef struct { int unsigned a; int unsigned b; } u4n_t;
  localparam u4n_t BN = '{a: 4, b: 8};
  typedef logic [BN.a-1:0] v4n_t;
endpackage

interface v4if import p4n::*; (input logic clk);
  v4n_t d;
endinterface

module v4leaf import p4n::*; (input logic clk);
  v4n_t d;
  assign d = '0;
endmodule

module v4mid import p4n::*; (input logic clk);
  v4n_t d;
  assign d = '0;
  v4leaf u_l (.clk(clk));
  v4if   u_i (.clk(clk));
endmodule

module v4never import p4n::*; (input logic clk);   // NEVER instantiated
  v4n_t d;
  assign d = '0;
endmodule

module v4top(input logic clk);
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      v4mid u_m (.clk(clk));
    end
  endgenerate
endmodule
