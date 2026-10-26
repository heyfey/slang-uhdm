// § genCaBitsMemberDefFold433v
module child #(parameter W = 2) ();
  typedef struct packed { logic [W-1:0] a; logic [2:0] b; } s_t;
  s_t s;
  logic [W-1:0] q;
  wire [7:0] y1, y2, y3;
  if (W <= 8) begin: g
    assign y1 = $bits(s.a);
    assign y2 = $bits(s.b);
    assign y3 = $bits(q[0]);
  end
endmodule
module top; child #(.W(5)) u1(); child u2(); endmodule
