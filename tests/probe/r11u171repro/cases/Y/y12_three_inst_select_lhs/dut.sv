// § selLhsBareDecRhsShared171
module f3(input [7:0] B, output [7:0] C);
  assign C[7:4] = 5;
  assign C[3] = 0;
  assign C[2:0] = B[2:0];
endmodule
module dut(input [7:0] a, output [7:0] x, y, z);
  f3 i5(a, x);
  f3 i6(a, y);
  f3 i7(a, z);
endmodule
