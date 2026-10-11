// § genProcIpsBoundInst282
package pk; parameter int P = 2; endpackage
module top import pk::*; (input logic clk, input logic [7:0] b, output logic [1:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_ff @(posedge clk) z[w] <= b[w +: P];
  end
endmodule
