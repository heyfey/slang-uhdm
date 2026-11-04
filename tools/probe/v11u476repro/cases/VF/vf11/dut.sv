// § fileMacroLenNormal476
`include "./sub/inc.svh"
module top;
  m u();
  initial $display(`__FILE__, 1);
endmodule
