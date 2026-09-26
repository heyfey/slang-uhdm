// § selLhsBareDecRhsShared171
module f(input logic [3:0] B, output logic [3:0] C);
  logic [7:0] t;
  assign t[7:4] = 10;
  assign t[3:0] = B;
  assign C = t[7:4] ^ t[3:0];
endmodule
module dut(input logic [3:0] a, b, output logic [3:0] x, y);
  f i0(a, x);
  f i1(b, y);
endmodule
