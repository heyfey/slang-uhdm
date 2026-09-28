// § tpFormalMacroAtExpansion188v
`define DECL_SET(NM) function void NM(B v); p = v; endfunction
package p;
  class base; endclass
  class c #(type B = base);
    B p;
    function void first(B a); p = a; endfunction
    `DECL_SET(second)
  endclass
endpackage
module top; endmodule
