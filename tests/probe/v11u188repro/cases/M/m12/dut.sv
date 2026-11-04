// § tpFormalMacroAtExpansion188v
`define DECL_ONE(NM) function void NM(T v); p = v; endfunction
`define DECL_TWO(A, B) `DECL_ONE(A) `DECL_ONE(B)
package p;
  class c #(type T = int);
    T p;
    function void first(T a); p = a; endfunction
    `DECL_TWO(second, third)
  endclass
endpackage
module top; endmodule
