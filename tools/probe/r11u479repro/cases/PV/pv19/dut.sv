// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  function automatic int f(vt_t x); return 0; endfunction
endpackage
module top; import t::*; endmodule
