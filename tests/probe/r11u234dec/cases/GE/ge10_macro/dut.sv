// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a method written by a macro, its formal written T
`define MK_SET(NM) function void NM(T v); endfunction
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
    `MK_SET(set_it)
  endclass
endpackage
