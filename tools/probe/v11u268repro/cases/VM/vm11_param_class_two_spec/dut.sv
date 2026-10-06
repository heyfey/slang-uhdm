// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
package p;
class c #(int N = 1);
  function string h(int a); return $sformatf("%s %0d", `VS, a + N); endfunction
endclass
endpackage
module top; p::c#(1) x; p::c#(2) y; string s;
  initial begin x = new; y = new; s = {x.h(1), y.h(2)}; end
endmodule
