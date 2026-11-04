// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; function automatic int f2(input bit b); return b; endfunction task tk2(input bit b); endtask endinterface
package t;
  typedef virtual ifc vt_t;
  class C; function int f(bit b); return b; endfunction task m(bit b); endtask endclass
endpackage
module top; import t::*; int x; logic clk; ifc u(clk);
  initial begin vt_t g; x = u.f2(g == null); end
endmodule
