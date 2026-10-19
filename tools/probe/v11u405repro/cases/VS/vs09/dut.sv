// § castSizeGenFence405
module top #(parameter n = 4, parameter w = $clog2(n)) (input clk, input logic [7:0] i, output logic [7:0] o[2]);
  for (genvar k = 0; k < 2; k++) begin : g
    always_ff @(posedge clk) o[k] <= w ' (i);
  end
endmodule
