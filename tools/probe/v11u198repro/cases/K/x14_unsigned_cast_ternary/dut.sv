// § genCaCastRhsRefUnnamed198
module top #(parameter type T = logic [2:0], parameter int N = 2, parameter int D = 1) (input logic s, input logic [2:0] q [2], input logic [3:0] b, input logic [3:0][2:0] pq, output logic [2:0] y [2], output logic [2:0] z, output logic [3:0] y4, output logic [2:0] yt [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = unsigned'(s ? q[0] : q[1]);
  end
endmodule
