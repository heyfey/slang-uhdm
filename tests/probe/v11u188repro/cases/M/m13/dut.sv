// § tpFormalMacroAtExpansion188v
`define DECL_SET(NM) function void NM(T v); p = v; endfunction
package p;
  class c #(type T = int);
    T p;
    `DECL_SET(first)
    function void mid(T a); p = a; endfunction
    `DECL_SET(last)
  endclass
endpackage
module top; endmodule
