// § stmtMethodCallArgWindow481v
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  class C; function void m(int v); endfunction endclass
endpackage
module top; import t::*;
  initial begin vt_t g; C c; c = new(); c.m(g == null); end
endmodule
