// § sysArgUnaryWholeSpan140
module top #(parameter int W = 4) (input logic [7:0] a, output logic [7:0] o);
  logic [$bits(~W)-1:0] y;
  assign y = a;
  assign o = y[7:0];
endmodule
