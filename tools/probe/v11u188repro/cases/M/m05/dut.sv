// § tpFormalIncludeOrder188 (control for § tpFormalMacroAtExpansion188v)
`define DECL_SET(NM) function void NM(T v); p = v; endfunction
`define DECL_GET(NM) function void NM(output T v); v = p; endfunction
package p;
  class c #(type T = int);
    T p;
    `DECL_GET(g1)
    function void first(T a); p = a; endfunction
    `DECL_SET(s1)
    function void last(T b); p = b; endfunction
  endclass
endpackage
module top; endmodule
