// § fileMacroLenNormal476
`define MYFILE `__FILE__
`define SHOW(x) $display(x, `MYFILE, `__LINE__)
`include "sub/../sub/./inc.svh"
module top;
  m u();
endmodule
