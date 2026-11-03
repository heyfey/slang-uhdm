// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  function automatic int f(); vt_t h; return 0; endfunction
  initial begin vt_t g; end
endmodule
