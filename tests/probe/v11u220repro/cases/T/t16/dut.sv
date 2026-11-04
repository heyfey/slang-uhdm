// § strLitShiftNeedsBacktick220
module top(output string o);
  initial o = "ab` c";
endmodule
