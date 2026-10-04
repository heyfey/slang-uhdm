// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a default naming a typedef of a typedef (typedef e_t e2_t)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  typedef e_t e2_t;
  class W #(type T=e2_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
