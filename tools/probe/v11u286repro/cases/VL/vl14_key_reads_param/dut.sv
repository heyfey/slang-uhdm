// § elabCastKeyBindsDefNet286
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
endpackage
module sub #(parameter int A = 1, parameter int B = 2);
  import pk::*;
  localparam p_t C = p_t'{a: A[3:0], b: B[3:0]};
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  sub #(.A(4)) u1();
  sub #(.B(5)) u2();
endmodule
