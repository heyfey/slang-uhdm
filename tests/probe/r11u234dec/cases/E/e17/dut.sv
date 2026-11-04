// § decode E: e01 plus a specialization W#(e_t) used by a module-free package variable
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
  W #(e_t) w;
endpackage
