// § elabUnszXzTypedAdjust427
module top(output [15:0] o);
  parameter logic [7:0] P = 'h1x;
  wire [15:0] w = P;
  assign o = w;
endmodule
