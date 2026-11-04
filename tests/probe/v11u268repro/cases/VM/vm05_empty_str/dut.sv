// § macroStrBodyLen268
`define VE `"`"
module top; int a;
  initial $display("%s%0d", `VE, a + 1);
endmodule
