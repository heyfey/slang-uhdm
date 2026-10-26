// § genCaBitsSelectKeeps433v
module top #(parameter W = 2) ();
  typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
  s_t s;
  logic [7:0] x;
  logic [3:0] m [4];
  logic [3:0][1:0] pk;
  wire [7:0] y1, y2, y3, y4, y5, y6, y7;
  if (W <= 4) begin: g
    assign y1 = $bits(s.a);
    assign y2 = $bits(x[3:0]);
    assign y3 = $bits(x[1]);
    assign y4 = $bits(m);
    assign y5 = $bits(pk[1]);
    assign y6 = $bits(m[0]);
    assign y7 = $size(pk);
  end
endmodule
