// § castSizeGenFence405
module top #(parameter n = 4) (input logic [7:0] i, output logic [7:0] o);
  localparam w = $clog2(n);
  logic [7:0] t = w ' (i);
  assign o = t;
endmodule
