// § elabCastKeyBindsDefNet286
module sub;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
  parameter p_t C = p_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  sub u1();
  sub #(.C(8'h33)) u2();
endmodule
