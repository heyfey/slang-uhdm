// § strLitShiftNeedsBacktick220
`define STR "x\\y"
module top(output string o);
  initial o = `STR;
endmodule
