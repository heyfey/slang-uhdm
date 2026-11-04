// § fileMacroLenNormal476
`define SHOW(x) $display(x, `__FILE__, `__LINE__)
`include "./sub/inc.svh"
module top;
  m u();
endmodule
