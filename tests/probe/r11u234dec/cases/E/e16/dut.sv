// § decode E: e15 with the non-parameterized class named Ac (name order puts W last)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    function void f(T a); endfunction
  endclass
  class Ac;
    function void g(e_t x); endfunction
  endclass
endpackage
