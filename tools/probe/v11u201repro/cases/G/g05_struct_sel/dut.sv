// § genBlockBitsKeepsSelect200
module top(output logic [31:0] z, output logic [31:0] z2);
  typedef struct packed { logic [3:0] a; logic [7:0] b; } s_t;
  s_t s;
  logic [3:0][7:0] m;
  if (1) begin : g
    assign z = $bits(s.b);
    assign z2 = $bits(m[1]) + $bits(m[2][3:0]);
  end
endmodule
