// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input clk, input logic [7:0] i, output logic [7:0] o, output logic [7:0] q);
  always_ff @(posedge clk) q <= w'(i);
  assign o = w'(i + 8'd1);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
