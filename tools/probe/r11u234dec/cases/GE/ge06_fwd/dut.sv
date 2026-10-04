// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a forward typedef of the enum before the class, defined after it
package p;
  typedef e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
  typedef enum bit { A=0, B=1 } e_t;
endpackage
