// § pkgPatReadTsNoParent131
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
endpackage
module top (output logic o);
  if (pk::P.a == 4'h1) begin : g
    assign o = 1'b1;
  end
endmodule
