// § castSizeParenComputed405
module top; endmodule
module m #(parameter n, parameter w = $clog2(n), parameter r = 0) (input clk, output logic [7:0] o);
  always_ff @(posedge clk) o <= (w)'(r);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
