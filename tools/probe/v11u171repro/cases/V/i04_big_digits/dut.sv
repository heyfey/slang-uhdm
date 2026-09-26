// § boundLitWrittenDigits172
module dut(input logic [7:0] a, output logic [7:0] y);
  logic [0000000000000000007:0] t;
  logic [7:000000000000000000000] u;
  assign t = a;
  assign u = t;
  assign y = u;
endmodule
