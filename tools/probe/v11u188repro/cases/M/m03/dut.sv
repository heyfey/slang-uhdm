// § tpFormalIncludeOrder188 (control for § tpFormalMacroAtExpansion188v)
`define DECL_SET(NM, TY) function void NM(TY v); p = v; endfunction
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `DECL_SET(second, T)
  endclass
endpackage
module top; endmodule
