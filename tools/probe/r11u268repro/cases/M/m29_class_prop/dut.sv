// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
class k;
  string n = `VS; int z = 3;
  function void f(); $display("%s %0d", `VS, z); endfunction
endclass
module top; endmodule
