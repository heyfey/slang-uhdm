// § elabUnszXzTypedAdjust427
module sub #(parameter int A = 4'b1x01, parameter logic [7:0] B = 4'b1x01, parameter bit [7:0] C = 4'b0x01, parameter int D = 40'h1x, parameter logic [3:0] E = 8'b1x01_0011, parameter integer F = 4'b1x01)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
