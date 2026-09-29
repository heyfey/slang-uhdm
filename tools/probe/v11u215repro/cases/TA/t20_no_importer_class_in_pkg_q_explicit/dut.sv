// § pkgTdAliasLastWriter215 — an importing package reaching the alias only by an explicit item, and a module importing a different item
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
  import p::alias_t;
endpackage
module m;
  import p::g_int_t;
endmodule
