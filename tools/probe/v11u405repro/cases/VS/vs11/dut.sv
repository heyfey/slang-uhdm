// § castSizeParenComputed405
module top #(parameter n = 16, parameter w = $clog2(n)) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  assign o = (w)'(i);
  assign p = w'(i);
endmodule
