// § tfArgOutsideClassOrder216 § pkgTdAliasLastWriter215 — an alias enum typedef read by class-method formals in its own package and another package, imported by a module and an interface
package p;
  typedef enum logic [1:0] {A0, B0, C0} base_e;
  typedef base_e e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class N;
    function void h(e_t z); endfunction
  endclass
endpackage
interface ifc;
  import p::*;
  e_t s;
endinterface
module top;
  import p::*;
  e_t v;
  ifc u();
endmodule
