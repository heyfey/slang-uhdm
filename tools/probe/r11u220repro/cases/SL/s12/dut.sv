// § strLitShiftNeedsBacktick220
`define ONE 1
module top(output string o, output int k);
   initial begin
      o = "a`b";
   end
endmodule
