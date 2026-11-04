// § tfArgOutsideClassOrder216 — an outside interface class's pure virtual prototype and an outside class implementing it
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  interface class I;
    pure virtual function void h(e_t z);
  endclass
  class C implements I;
    virtual function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
