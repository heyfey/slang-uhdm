// § selLhsBareDecRhsShared171
module f(input [3:0] B, output [3:0] C);
  wire [3:0] m [0:1];
  assign m[0] = 0;
  assign m[1][2:0] = 3;
  assign C = m[0] | m[1] | B;
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f i0(a, x);
  f i1(b, y);
endmodule
