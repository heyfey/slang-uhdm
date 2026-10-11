// § elabCastKeyBindsDefNet286
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
endpackage
module sub import pk::*; #(parameter p_t C = 8'h12);
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  import pk::*;
  sub #(.C(p_t'{a: 4'd3, b: 4'd4})) u1();
  sub u2();
endmodule
