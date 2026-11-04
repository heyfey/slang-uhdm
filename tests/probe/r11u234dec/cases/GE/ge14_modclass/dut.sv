// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: the class declared in a module, the typedef in a package
package p;
  typedef enum bit { A=0, B=1 } e_t;
endpackage
module top;
  import p::*;
  class W #(type T=e_t);
    T m;
    function void f(T a); endfunction
  endclass
  W w;
endmodule
