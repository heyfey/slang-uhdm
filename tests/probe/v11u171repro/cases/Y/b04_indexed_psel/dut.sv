// § selLhsBareDecRhsShared171
module f #(parameter I = 1) (input [3:0] B, output [3:0] C);
  assign C[I+:2] = 0;
  assign C[3] = 0;
  assign C[0] = B[0];
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f #(1) i0(a, x);
  f #(1) i1(b, y);
endmodule
