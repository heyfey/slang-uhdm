// § sysArgUnaryConstSelToken140v
module top(input logic [31:0] x, input logic [7:0] a, output logic [7:0] o);
  assign o = x[0 +: $bits(~a)];
endmodule
