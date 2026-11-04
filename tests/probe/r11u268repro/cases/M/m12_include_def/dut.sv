// § macroStrBodyLen268
`include "defs.svh"
module top;
  int a, b;
  initial $display("%s %0d", `VS, a + b);
endmodule
