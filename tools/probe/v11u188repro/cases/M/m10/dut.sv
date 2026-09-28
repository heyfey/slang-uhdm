// § tpFormalMacroAtExpansion188v
`define DECL_SET(NM) function void set_``NM(T v); p = v; endfunction
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `DECL_SET(second)
  endclass
endpackage
module top; endmodule
