// § tpFormalMacroAtExpansion188v
`include "m04_mac.svh"
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `DECL_SET(second)
  endclass
endpackage
module top; endmodule
