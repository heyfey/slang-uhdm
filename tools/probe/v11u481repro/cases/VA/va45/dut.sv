// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; function automatic int f2(input bit b); return b; endfunction task tk2(input bit b); endtask endinterface
package t;
  typedef virtual ifc vt_t;
  class C; function int f(bit b); return b; endfunction task m(bit b); endtask endclass
endpackage
module top; import t::*; int x;
  initial begin vt_t g; C c; c = new(); x = c.f(g == null); end
endmodule
