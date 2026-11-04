// § sysArgUnaryConstSelToken140v
module dut(input logic [3:0] a, input logic [1:0][7:0] m, output logic [3:0] y);
  assign y = m[1][0 +: $bits(~a)];
endmodule
