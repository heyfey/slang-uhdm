// § genScopeProcPsNamedByScope154 § genProcFoldTsKeepsScope154 § genLpOperandTsNoParent152
module rs #(parameter int Q [2] = '{2, 3}) (input clk, input [7:0] x, output [7:0] o);
  for (genvar a = 0; a < 1; a++) begin : ga
    for (genvar k = 0; k < 2; k++) begin : gk
      localparam int L = Q[k];
      reg [7:0] v;
      always @(posedge clk) v[L-1:0] <= x[L-1:0];
      assign o[k] = v[0];
    end
  end
endmodule
module top(input clk, input [7:0] x, output [7:0] o); rs r(clk, x, o); endmodule
