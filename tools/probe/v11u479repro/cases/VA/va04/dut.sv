// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  function automatic vt_t get(); return null; endfunction
endpackage
module top; import t::*; endmodule
