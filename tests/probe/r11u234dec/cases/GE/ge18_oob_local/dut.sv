// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: an out-of-body definition's local written T (the fence: not claimed)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    extern function void f(T a);
  endclass
  function void W::f(T a);
    T l;
    l = a;
  endfunction
endpackage
