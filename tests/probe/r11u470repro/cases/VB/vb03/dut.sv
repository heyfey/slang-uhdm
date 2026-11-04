// § specValueArgRefObj470 (residue control: the package virtual-interface typedef listing, ParamEmit emitPackage, the sister ground)
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
