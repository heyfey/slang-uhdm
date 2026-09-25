// § sysArgUnaryConstSelToken140v
module dut(input logic [3:0] a, input logic [15:0] x, input logic [1:0] k, output logic [3:0] y);
  assign y = x[k*4 +: $bits(!a) + 3];
endmodule
