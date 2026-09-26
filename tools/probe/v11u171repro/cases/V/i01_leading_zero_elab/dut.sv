// § boundLitWrittenDigits172
module sub #(parameter W = 4) (input logic [07:00] a, output logic [W-1:00] y);
  logic [0_7:0_0] t;
  assign t = a;
  assign y = t[W-1:0];
endmodule
module dut(input logic [7:0] a, output logic [3:0] y, output logic [5:0] z);
  sub #(4) u0(a, y);
  sub #(6) u1(a, z);
endmodule
