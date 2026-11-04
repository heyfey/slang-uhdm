// § castSizeGenFence405
module top; endmodule
module m #(parameter n) (input logic [7:0] i, output logic [7:0] o);
  localparam w = $clog2(n);
  wire [7:0] t = w ' (i);
  assign o = t;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
