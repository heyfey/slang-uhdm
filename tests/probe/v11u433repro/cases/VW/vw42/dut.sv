// § genCaBitsMemberDefFold433v
module top #(parameter W = 2) ();
  typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
  wire [7:0] y1, y2;
  if (W <= 4) begin: g
    s_t s;
    assign y1 = $bits(s.a);
    assign y2 = $bits(s);
  end
endmodule
