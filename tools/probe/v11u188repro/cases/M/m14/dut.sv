// § tpFormalMacroAtExpansion188v
`define DECL_SET(NM) function void NM(T v); p = v; endfunction
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `include "m14_impl.svh"
  endclass
endpackage
module top; endmodule
