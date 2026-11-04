// § strLitShiftNeedsBacktick220
module top(output string o);
  initial o = "a\x41\0b\\";
endmodule
