// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  int a, b;
  task t(); $display("%s %0d", `VS, a + b); endtask
  initial t();
endmodule
