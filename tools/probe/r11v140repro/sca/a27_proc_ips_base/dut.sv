// § sysArgUnaryConstSelToken140v
module top(input logic [31:0] x, input logic [7:0] a, output logic [1:0] o);
  always_comb o = x[$bits(-a) +: 2];
endmodule
