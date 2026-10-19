// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w, r = 0) (input clk, output logic [7:0] o, output logic [7:0] p);
  always @(posedge clk) o <= (w)'(r);
  assign p = w'(r+1);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
