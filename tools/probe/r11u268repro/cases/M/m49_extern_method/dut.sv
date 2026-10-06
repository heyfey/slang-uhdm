// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
class k;
  int z;
  extern function string f();
endclass
function string k::f(); return $sformatf("%s %0d", `VS, this.z + 1); endfunction
module top; endmodule
