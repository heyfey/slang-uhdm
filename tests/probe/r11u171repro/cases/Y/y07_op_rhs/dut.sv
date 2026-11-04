// § selLhsBareDecRhsShared171
module f3(input [3:0] B, output [3:0] C);
  assign C = B + 1;
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f3 i5(a, x);
  f3 i6(b, y);
endmodule
