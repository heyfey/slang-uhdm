// § decode E: e15 plus a package function after both classes (W's T formal, Zc's e_t formal, pf's e_t formal)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    function void f(T a); endfunction
  endclass
  class Zc;
    function void g(e_t x); endfunction
  endclass
  function void pf(e_t y); endfunction
endpackage
