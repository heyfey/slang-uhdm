// § specValueArgRefObj470 (residue control: the package virtual-interface typedef listing, ParamEmit emitPackage, the sister ground)
interface ifc #(int A = 8, int D = 8) (input logic clk); logic [A-1:0] a; endinterface
package t;
  typedef virtual ifc #(16, 32) vt_t;
endpackage
package u;
  import t::*;
  class C; vt_t h; endclass
endpackage
module top; import u::*; C c; endmodule
