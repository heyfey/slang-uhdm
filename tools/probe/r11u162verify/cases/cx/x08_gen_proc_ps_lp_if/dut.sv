// § genScopeProcPsNamedByScope154 § genProcFoldTsKeepsScope154 § genLpOperandTsNoParent152
module rs #(parameter int P = 4, parameter int Q [2] = '{1, 2}) (input clk, input [7:0] x, output [7:0] o);
  if (P > 2) begin : gi
    for (genvar k = 0; k < 2; k++) begin : gk
      localparam int L = Q[k];
      reg [7:0] v;
      always @(posedge clk) v[P-1:0] <= x[P-1:0] + L;
      assign o[k] = v[L];
    end
  end
endmodule
module top(input clk, input [7:0] x, output [7:0] o); rs r(clk, x, o); endmodule
