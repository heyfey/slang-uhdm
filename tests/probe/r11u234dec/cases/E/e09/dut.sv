// § decode E: two classes with a T=e_t formal each (class compile order by name: Zc written first, Ac second)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class Zc #(type T=e_t);
    function void f(T a); endfunction
  endclass
  class Ac #(type T=e_t);
    function void f(T a); endfunction
  endclass
endpackage
