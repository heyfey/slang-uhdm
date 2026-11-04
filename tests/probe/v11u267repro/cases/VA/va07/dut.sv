// § caFoldParentUnboundLhs267
package fp;
  localparam int N = 3;
  typedef struct packed { logic [5:0] a; logic [5:0] b; } pr_t;
endpackage
module fc import fp::*; (output pr_t [1:0] o);
  pr_t [1:0] r;
  for (genvar i = 0; i < 2; i++) begin : g
    assign r[i].a = {N{2'b01}};
  end
  assign r[0].b = {2*N{1'b0}};
  assign r[1].b = {fp::N{2'b11}};
  assign o = r;
endmodule
module top(output fp::pr_t [1:0] o);
  fc u_fc(.o(o));
endmodule
