// § castSizeGenFence405
module top #(parameter n = 4) (input clk, input logic [7:0] i, output logic [7:0] o);
  localparam w = $clog2(n);
  always_ff @(posedge clk) o <= w'(i);
endmodule
