// § decode E: a package function with an e_t formal written before the class's T formal
package p;
  typedef enum bit { A=0, B=1 } e_t;
  function void pf(e_t x); endfunction
  class W #(type T=e_t);
    function void f(T a); endfunction
  endclass
endpackage
