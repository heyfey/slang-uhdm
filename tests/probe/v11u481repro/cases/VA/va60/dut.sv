// § stmtMethodCallArgWindow481v
interface ifc (input logic clk); logic a; function automatic int f2(input bit b); return b; endfunction task tk2(input bit b); endtask endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic clk; ifc u(clk);
  initial begin vt_t g; u.tk2(g == null); g = null; end
endmodule
