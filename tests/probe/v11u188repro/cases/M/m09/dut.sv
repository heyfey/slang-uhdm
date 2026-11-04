// § tpFormalIncludeOrder188 (control for § tpFormalMacroAtExpansion188v)
package p;
  class c #(type T = int);
    T p;
`ifdef NOPE
    function void dead(T d); p = d; endfunction
`endif
    `include "m09_m.svh"
  endclass
endpackage
module top; endmodule
