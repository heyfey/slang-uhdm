// § strLitShiftNeedsBacktick220
module top(output string o);
  initial o = "a\\b`	c";
endmodule
