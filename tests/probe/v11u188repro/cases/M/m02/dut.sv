// § tpFormalIncludeOrder188 (control for § tpFormalMacroAtExpansion188v)
`define DECL_SET(NM) function void NM(T v); p = v; endfunction
package p;
  class c #(type T = int);
    T p;
    `DECL_SET(first)
    function void second(T a); p = a; endfunction
  endclass
endpackage
module top; endmodule
