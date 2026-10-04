// § decode E: a scalar vector typedef default with a formal written T
package p;
  typedef bit [3:0] n_t;
  class W #(type T=n_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
