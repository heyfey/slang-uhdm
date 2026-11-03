// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  function automatic bit f(vt_t v); return v == null; endfunction
  task tk(input bit b); endtask
  initial begin vt_t g; tk(f(g)); end
endmodule
