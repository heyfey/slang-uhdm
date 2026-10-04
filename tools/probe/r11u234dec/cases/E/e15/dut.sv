// § decode E: a non-parameterized class Zc with an e_t formal beside the parameterized class W's T formal (name order puts Zc last)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    function void f(T a); endfunction
  endclass
  class Zc;
    function void g(e_t x); endfunction
  endclass
endpackage
