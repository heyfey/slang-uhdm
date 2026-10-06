// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define V2 `"`NM``_```MJ`"
module top; int a;
  initial $display("%s %s %0d", `VS, `V2, a + 1);
endmodule
