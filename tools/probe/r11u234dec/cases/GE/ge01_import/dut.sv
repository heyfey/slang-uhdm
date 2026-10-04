// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: the typedef in another package imported by the class's package
package q;
  typedef enum bit { A=0, B=1 } e_t;
endpackage
package p;
  import q::*;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
    static function void g(); T l = l.first(); l = l.next(); endfunction
  endclass
endpackage
