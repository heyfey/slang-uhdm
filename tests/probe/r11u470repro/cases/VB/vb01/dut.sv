// § specValueArgRefObj470 (residue control: the package virtual-interface typedef listing, ParamEmit emitPackage, the sister ground)
interface ifc #(int A = 8, int D = 8) (input logic clk); logic [A-1:0] a; endinterface
package t;
  class K; localparam w = 16; localparam d = 32; endclass
  typedef virtual ifc #(K::w, K::d) vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
