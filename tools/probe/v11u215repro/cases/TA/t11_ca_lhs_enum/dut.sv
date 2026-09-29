// § pkgTdAliasLastWriter215 — an output typed by the enum alias assigned continuously (the caUnparent control) and a second module importing
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module m(output p::alias_t o);
  assign o = p::A;
endmodule
module n;
  import p::*;
  alias_t v;
endmodule
