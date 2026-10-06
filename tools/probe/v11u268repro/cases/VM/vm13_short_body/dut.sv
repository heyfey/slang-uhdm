// § macroStrBodyLen268
`define A x
`define VL `"`A``_```A``_```A``_```A``_```A`"
module top; int a;
  initial $display("%s %0d", `VL, a + 1);
endmodule
