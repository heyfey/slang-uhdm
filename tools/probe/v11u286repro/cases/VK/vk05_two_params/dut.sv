// § elabCastKeyBindsDefNet286
module sub;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
  localparam p_t C = p_t'{a: 4'd1, b: 4'd2};
  localparam p_t D = p_t'{a: 4'd5, b: 4'd6};
  logic [7:0] o, q;
  assign o = C;
  assign q = D;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
