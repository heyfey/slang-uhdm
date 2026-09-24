// § sysArgUnaryConstSelToken140v
module top(input logic [7:0] a, input logic [1:0][31:0] y, output logic [7:0] o);
  assign o = y[1][8 +: $bits(~a)];
endmodule
