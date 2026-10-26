// § genCaBitsMemberDefFold433v
module top #(parameter W = 2) ();
  typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
  s_t s;
  wire [7:0] y, z, v;
  if (W <= 4) begin: g
    assign y = $bits(s);
    assign z = $clog2(W + 7);
    assign v = $bits(s.b);
  end
endmodule
