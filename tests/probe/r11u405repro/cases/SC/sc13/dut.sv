// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w, r = 0) (input clk, output logic [7:0] o);
  always @(posedge clk) o <= (w)'(r);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
