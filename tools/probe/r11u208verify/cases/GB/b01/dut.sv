// § genBlockBitsKeepsSelect200
module sub (input logic [31:0] x, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3);
  typedef struct packed { logic [5:0] f; logic [1:0] g; } s_t;
  s_t s;
  assign s = x[7:0];
  for (genvar i = 0; i < 2; i++) begin : g
    wire [31:0] w;
    assign w = $bits(x[i*4 +: 4]);
  end
  if (1) begin : h
    assign z1 = $bits(s.f);
    assign z2 = $bits(x[3:0]) + $bits(x[2]);
  end
  assign z3 = g[1].w;
endmodule
module top (input logic [31:0] x, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3);
  sub u (.*);
endmodule
