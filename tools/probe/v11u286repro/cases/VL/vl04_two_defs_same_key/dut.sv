// § elabCastKeyBindsDefNet286
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
endpackage
module s1;
  import pk::*;
  localparam p_t C = p_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endmodule
module s2;
  import pk::*;
  localparam p_t D = p_t'{a: 4'd3, b: 4'd4};
  logic [7:0] o;
  assign o = D;
endmodule
module top;
  s1 u1();
  s1 u2();
  s2 v1();
  s2 v2();
endmodule
