// § fileMacroLenNormal476
`define LOC $sformatf("%s:%0d", `__FILE__, `__LINE__)
`include "./sub/inc.svh"
module top;
  m u();
endmodule
