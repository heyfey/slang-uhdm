// § castSizeGenFence405
module top; endmodule
module m #(parameter n) (input logic [7:0] i, output logic [7:0] o);
  localparam w = $clog2(n);
  assign o = w ' (i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
