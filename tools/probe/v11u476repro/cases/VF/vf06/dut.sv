// § fileMacroLenNormal476
`define SHOW(a, b) $display(a, `__FILE__, b, `__LINE__)
`include "./sub/../sub/inc.svh"
module top;
  m u();
endmodule
