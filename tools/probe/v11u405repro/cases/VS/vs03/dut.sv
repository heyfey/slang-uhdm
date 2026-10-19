// § castSizeGenFence405
module top; endmodule
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  logic [7:0] t = w'(i);
  assign o = t ^ w'(i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
