// § pkgTdAliasLastWriter215 — the typedef read through a two-package re-export chain (p -> q -> r) and through an interface port of a module
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
package q;
  import p::*;
  export p::alias_t;
  alias_t qa;
endpackage
package r;
  import q::*;
  export q::alias_t;
  function automatic void rf(alias_t x); endfunction
endpackage
interface ifc;
  import r::*;
  alias_t s;
endinterface
module m(ifc port);
  import r::*;
  alias_t v;
endmodule
module top;
  ifc u();
  m u_m(.port(u));
endmodule
