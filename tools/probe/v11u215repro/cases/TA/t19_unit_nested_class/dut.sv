// § pkgTdAliasLastWriter215 — a nested class inside a $unit class in an importing file (the nested class a candidate writer)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
import p::*;
class outer;
  class inner;
    int z;
  endclass
endclass
module m;
endmodule
