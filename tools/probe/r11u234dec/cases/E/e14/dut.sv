// § decode E: the class's T formal written before a package function with an e_t formal (compile order: which is last)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    function void f(T a); endfunction
  endclass
  function void pf(e_t x); endfunction
endpackage
