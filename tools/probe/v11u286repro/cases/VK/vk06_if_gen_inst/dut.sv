// § elabCastKeyBindsDefNet286
module sub;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p_t;
  localparam p_t C = p_t'{a: 4'd1, b: 4'd2};
  logic [7:0] o;
  assign o = C;
endmodule
module top;
  if (1) begin : g
    sub u1();
  end
  sub u2();
endmodule
