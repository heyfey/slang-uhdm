// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  function automatic int f(vt_t x); vt_t y; y = x; return 0; endfunction
endmodule
