// § strLitShiftNeedsBacktick220
module top(output string o);
`include "inc_t20.svh"
  initial begin
    `SETS(o)
    si = "m\\n";
  end
endmodule
