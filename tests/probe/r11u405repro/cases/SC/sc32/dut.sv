// § castSizeParenComputed405
module top #(parameter n = 4, parameter w = $clog2(n), parameter r = 0) (input clk, output logic [7:0] o);
  always_ff @(posedge clk) o <= (w)'(r);
endmodule
