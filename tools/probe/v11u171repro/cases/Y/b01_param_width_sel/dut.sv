// § selLhsBareDecRhsShared171
module f #(parameter W = 4) (input [W-1:0] B, output [W-1:0] C);
  assign C[W-1:2] = 0;
  assign C[1:0] = B[1:0];
endmodule
module dut(input [3:0] a, input [5:0] b, output [3:0] x, output [5:0] y);
  f #(4) i0(a, x);
  f #(6) i1(b, y);
endmodule
