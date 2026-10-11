// § elabCastKeyBindsDefNet286
module sub #(parameter int W = 1);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
  localparam p_t C = p_t'{a: W, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  sub #(.W(1)) u1();
  sub #(.W(3)) u2();
endmodule
