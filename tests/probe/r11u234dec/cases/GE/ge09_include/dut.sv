// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: the class's methods in an included file
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
`include "w_methods.svh"
    function void h(T z); endfunction
  endclass
endpackage
