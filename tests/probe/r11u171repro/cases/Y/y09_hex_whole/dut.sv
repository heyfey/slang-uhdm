// § selLhsBareDecRhsShared171
module f3(input [3:0] B, output [3:0] C, output [1:0] D);
  assign C = 4'hA;
  assign D = 1;
endmodule
module dut(input [3:0] a, b, output [3:0] x, y, output [1:0] p, q);
  f3 i5(a, x, p);
  f3 i6(b, y, q);
endmodule
