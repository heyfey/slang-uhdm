// § pkgTdAliasLastWriter215 — an alias of an alias (typedef alias_t alias2_t) and a class alias of a class alias, used by a module importer
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  typedef alias_t alias2_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef g_int_t g2_t;
  class c;
    function void set(alias2_t v, g2_t w); endfunction
  endclass
endpackage
module m;
  import p::*;
  alias2_t x;
endmodule
