// § decode E: the default written package-qualified (type T = p::e_t) inside its own package
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=p::e_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
