// § genCaCastRhsRefUnnamed198
module top #(parameter type T = logic [2:0], parameter int N = 2, parameter int D = 1) (input logic s, input logic [2:0] q [2], input logic [3:0] b, input logic [3:0][2:0] pq, output logic [2:0] y [2], output logic [2:0] z, output logic [3:0] y4, output logic [2:0] yt [2]);
  typedef logic [2:0] t3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = t3'({s, b[i], s});
  end
endmodule
