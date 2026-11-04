// § selLhsBareDecRhsShared171
module f3(input [3:0] B, output [3:0] C);
  assign C[1:0] = B[1:0];
  assign C[3:2] = '0;
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f3 i5(a, x);
  f3 i6(b, y);
endmodule
