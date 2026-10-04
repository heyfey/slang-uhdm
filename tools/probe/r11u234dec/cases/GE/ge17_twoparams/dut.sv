// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: two independent type parameters with two enum defaults
package p;
  typedef enum bit { A=0, B=1 } e_t;
  typedef enum bit [1:0] { X=0, Y=1 } f_t;
  class W #(type T=e_t, type U=f_t);
    static T m;
    static U n;
    function void f(T a, U b); endfunction
  endclass
endpackage
