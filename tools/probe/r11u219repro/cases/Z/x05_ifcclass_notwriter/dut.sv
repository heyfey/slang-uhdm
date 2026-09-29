// § enumClsWriterUnitScopeOnly219 — a class declared inside an importing interface is no writer (r11u216's w11 shape, two interfaces); the module importing the package writes last
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
interface zfc;
  import p::*;
  class N;
    e_t q;
  endclass
endinterface
module top;
  import p::*;
  ifc u();
  zfc w();
  e_t v;
endmodule
