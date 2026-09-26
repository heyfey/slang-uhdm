// § selLhsBareDecRhsShared171
module f(input [7:0] B, output [7:0] C);
  assign C[7:4] = 15;
  assign C[3:0] = 4294967295;
endmodule
module dut(input [7:0] a, b, output [7:0] x, y);
  f i0(a, x);
  f i1(b, y);
endmodule
