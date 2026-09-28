// § tpFormalIncludeOrder188 (control for § tpFormalMacroAtExpansion188v)
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `include "m08_m.svh"
    function void last(T b); p = b; endfunction
  endclass
endpackage
module top; endmodule
