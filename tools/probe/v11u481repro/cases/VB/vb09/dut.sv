// § pkgVifTdParamNameSpan481
interface ifc #(parameter W = 8, parameter V = 2) (input logic clk); logic [W-1:0] a; modport mp(input a); endinterface
package t;
  typedef virtual ifc #(8).mp vt_t;
endpackage
package q; import t::*;
  function automatic void f(); vt_t g; g = null; endfunction
endpackage
module top; import q::*; import t::*; vt_t h;
endmodule
