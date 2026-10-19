// § unitParamBasedLitFold412
localparam int LI = 4'sb1111;
parameter byte PBY = 8'sb10000000;
parameter P0 = 4'sb0111;
parameter PH = 4'shF;
module top(output int o);
  assign o = LI + PBY;
endmodule
