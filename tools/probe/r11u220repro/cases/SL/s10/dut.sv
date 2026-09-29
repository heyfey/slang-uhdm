// § strLitShiftNeedsBacktick220
module top(output string o);
   initial begin
      o = "a\101b";
   end
endmodule
