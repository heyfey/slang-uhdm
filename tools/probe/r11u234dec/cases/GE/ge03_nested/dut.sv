// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: the parameterized class nested in another package class
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class O;
    class W #(type T=e_t);
      static T m;
      function void f(T a); endfunction
    endclass
  endclass
endpackage
