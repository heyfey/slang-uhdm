// § selLhsBareDecRhsShared171
module sub (output wire [7:0] c);
  assign c[3:0] = 4'd5;
  assign c[5:4] = -1;
  assign c[7:6] = 3;
endmodule
module dut (output wire [7:0] a, b);
  sub u1(a);
  sub u2(b);
endmodule
