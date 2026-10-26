// § connIdxUnitParamFold433
localparam XF = 4, ZF = 2;
module child(input a, b, output y);
  assign y = a & b;
endmodule
module top(input [7:0] ccr, output y);
  child c(.a(ccr[XF]), .b(ccr[ ZF]), .y(y));
endmodule
