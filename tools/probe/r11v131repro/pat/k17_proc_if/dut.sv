// § pkgPatReadTsNoParent131
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
endpackage
module top (input logic [3:0] i, output logic o);
  always_comb if (i == pk::P.b) o = 1'b1; else o = 1'b0;
endmodule
