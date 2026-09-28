// § tfArgOutsideClassOrder216 — the outside class declared in an interface (declined)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
interface ifc;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endinterface
module top;
  import p::*;
  ifc u();
  e_t v;
endmodule
