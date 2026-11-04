// § selLhsBareDecRhsShared171
module g(input [3:0] B, output [3:0] C);
  assign C[3:1] = 0;
  assign C[0] = B[0];
endmodule
module f(input [3:0] B, output [3:0] C, D);
  g u0(B, C);
  g u1(~B, D);
endmodule
module dut(input [3:0] a, output [3:0] x, y, z, w);
  f i0(a, x, y);
  f i1(~a, z, w);
endmodule
