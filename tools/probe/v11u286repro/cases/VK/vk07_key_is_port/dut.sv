// § elabCastKeyBindsDefNet286
module sub (input logic [3:0] a);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
  localparam p_t C = p_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  logic [3:0] x;
  sub u1(.a(x));
  sub u2(.a(x));
endmodule
