// § selLhsBareDecRhsShared171
module f(input [3:0] B, output [3:0] C);
  assign C[3:2] = 5;
  assign C[1] = 1;
  assign C[0] = B[0];
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f i0(a, x);
  f i1(b, y);
endmodule
