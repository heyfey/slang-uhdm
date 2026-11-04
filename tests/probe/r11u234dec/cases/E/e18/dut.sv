// § decode E: a non-parameterized class with an e_t formal written before a package function with an e_t formal
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class Zc;
    function void g(e_t x); endfunction
  endclass
  function void pf(e_t y); endfunction
endpackage
