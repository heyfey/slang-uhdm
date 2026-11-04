// § fileMacroLenNormal476
`define INFO(m) \
  $display("%s %s %0d", m, \
           `__FILE__, `__LINE__)
`include "./sub/inc.svh"
module top;
  m u();
endmodule
