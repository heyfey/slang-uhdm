// § selLhsBareDecRhsShared171
module f3 #(parameter P = 2) (input [3:0] B, output [3:0] C);
  assign C = P;
endmodule
module dut(input [3:0] a, b, output [3:0] x, y);
  f3 i5(a, x);
  f3 #(.P(3)) i6(b, y);
endmodule
