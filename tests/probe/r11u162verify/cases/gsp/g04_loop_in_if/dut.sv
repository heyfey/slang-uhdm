// § genScopeProcPsNamedByScope154
module rs #(parameter int N = 2) (input clk, input [7:0] x, output [7:0] o);
  if (N > 1) begin : outer
    for (genvar k = 0; k < N; k++) begin : inner
      reg [3:0] v;
      always @(posedge clk) v[3:1] <= x[k*4 +: 3];
      assign o[k*4 +: 4] = v;
    end
  end
endmodule
module top(input clk, input [7:0] x, output [7:0] o); rs r(clk, x, o); endmodule
