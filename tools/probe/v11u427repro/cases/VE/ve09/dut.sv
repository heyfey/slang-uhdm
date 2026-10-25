// § typedLitElabAdjustLogic427
module top(output [15:0] o);
  parameter logic [63:0] P = 64'hFFFF_FFFF_FFFF_FFFF;
  assign o = P;
endmodule
