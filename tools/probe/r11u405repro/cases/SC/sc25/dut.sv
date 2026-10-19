// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input clk, input logic [7:0] i, output logic [7:0] o);
  if (w > 1) begin : g
    always_ff @(posedge clk) o <= w'(i);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
