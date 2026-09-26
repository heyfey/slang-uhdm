// § selLhsBareDecRhsShared171
module sub (output wire [3:0] m [2]);
  assign m[1][2] = 1;
  assign m[0][3:2] = 2;
endmodule
module dut (output wire [3:0] a [2], b [2]);
  sub u1(a);
  sub u2(b);
endmodule
