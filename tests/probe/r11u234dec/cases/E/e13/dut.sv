// § decode E: a chain (type U = T) with the formal written U
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t, type U=T);
    static T m;
    function void f(U a); endfunction
  endclass
endpackage
