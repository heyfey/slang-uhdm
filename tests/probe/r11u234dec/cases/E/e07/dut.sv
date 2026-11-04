// § decode E: a struct typedef default with a formal written T
package p;
  typedef struct packed { bit a; bit b; } s_t;
  class W #(type T=s_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
