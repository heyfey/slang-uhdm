// § stmtMethodCallArgWindow481v
interface ifc (input logic clk); logic a; task tk2(input int x); endtask endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic clk; ifc u(clk);
  initial begin vt_t g; u.tk2(g == null); end
endmodule
