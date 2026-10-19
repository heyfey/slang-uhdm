// § castSizeGenFence405
module top; endmodule
module m #(parameter n, parameter w = $clog2(n)) (input logic [7:0] i, output logic [7:0] o);
  if (n > 1) begin : g
    assign o = w ' (i);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
