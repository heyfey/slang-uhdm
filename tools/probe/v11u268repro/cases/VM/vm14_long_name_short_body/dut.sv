// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define LONGER_NAME_THAN_BODY_ZZZZZZZZ `"q`"
module top; int a;
  initial $display("%s %0d", `LONGER_NAME_THAN_BODY_ZZZZZZZZ, a + 1);
endmodule
