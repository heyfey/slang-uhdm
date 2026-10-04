// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a packed union typedef default
package p;
  typedef union packed { bit [1:0] a; bit [1:0] b; } u_t;
  class W #(type T=u_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
