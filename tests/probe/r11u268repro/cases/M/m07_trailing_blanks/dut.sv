// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define VB `"`NM``-```MJ`"    
module top;
  int a, b;
  initial $display("%s %0d", `VB, a + b);
endmodule
