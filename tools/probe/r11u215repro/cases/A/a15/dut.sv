// § pkgTdAliasLastWriter215 — a $unit class in a file without an import is no writer, the module is
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  typedef gen#(bit) g_bit_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
class env;
  int q;
endclass
module m;
  import p::*;
endmodule
