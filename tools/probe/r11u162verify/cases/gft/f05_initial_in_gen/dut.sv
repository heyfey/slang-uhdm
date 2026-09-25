// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (output reg [7:0] o);
  if (P > 1) begin : gb
    initial o[P-1:0] = '1;
  end
endmodule
module top(output [7:0] o); rs r(o); endmodule
