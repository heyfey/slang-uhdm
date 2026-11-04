// § fileMacroLenNormal476
`define INFO(msg) \
  $display("%s %s %0d", msg, \
           `__FILE__, `__LINE__)
`include "./sub/inc.svh"
module top;
  m u();
endmodule
