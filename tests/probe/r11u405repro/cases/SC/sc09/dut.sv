// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input clk, input logic [7:0] i, output logic [7:0] o);
  always_ff @(posedge clk) begin
    if (i == w'(0)) o <= w'(1);
    else o <= i;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
