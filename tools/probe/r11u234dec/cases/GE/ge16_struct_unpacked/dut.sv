// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: an unpacked struct typedef default with a property, a local and a formal
package p;
  typedef struct { int a; bit b; } s_t;
  class W #(type T=s_t);
    T m;
    function void f(T a); T l; l = a; endfunction
  endclass
endpackage
