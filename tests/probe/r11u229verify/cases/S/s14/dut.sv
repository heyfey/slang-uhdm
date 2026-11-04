// § strLitPpEscIdShift224 (an included header holding two declarations on the literal's line)
module top(output string o, output int k);
  `include "inc.svh"
  assign o = H;
  assign k = HK;
endmodule
