// § pkgTdAliasLastWriter215 — a class inside an importing package using the alias (the package is the writer, not its class)
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
  class d;
    alias_t v;
    g_int_t w;
  endclass
endpackage
module m;
endmodule
