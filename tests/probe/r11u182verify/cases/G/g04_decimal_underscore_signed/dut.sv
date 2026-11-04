// § selLhsBareDecRhsShared171
module sub (output wire signed [15:0] c, output wire [3:0] d [2]);
  assign c[15:8] = 1_0;
  assign c[7] = 0;
  assign c[6:0] = 12;
  assign d[1][1:0] = 2;
endmodule
module dut (output wire signed [15:0] a, b, output wire [3:0] e [2], f [2]);
  sub u1(a, e);
  sub u2(b, f);
endmodule
