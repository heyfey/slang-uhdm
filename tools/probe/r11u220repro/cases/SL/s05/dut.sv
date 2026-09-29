// § strLitShiftNeedsBacktick220
module top(output string o);
   initial begin
      o = "a\\\\b";
   end
endmodule
