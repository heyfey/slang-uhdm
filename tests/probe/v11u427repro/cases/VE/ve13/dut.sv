// § typedLitElabAdjustLogic427
module top(output [15:0] o);
  parameter logic [7:0] P = 12'hABC;
  wire [7:0] w = P + 1;
  assign o = P;
endmodule
