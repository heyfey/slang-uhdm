// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  class C; task tk(); vt_t g; endtask function int f(); vt_t q; return 0; endfunction endclass
endpackage
module top; import t::*; C c; endmodule
