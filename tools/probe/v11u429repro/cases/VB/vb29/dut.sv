// § genBodyBitsOuterNameKeeps429
module sub #(parameter N = 2) (output logic [7:0] y [N]);
  logic [N+1:0] x;
  for (genvar i = 0; i < N; i++) begin: g
    always_comb y[i] = $bits(x) + i;
  end
endmodule
module top (output logic [7:0] a [3], b [2]);
  sub #(3) u1 (a);
  sub u2 (b);
endmodule
