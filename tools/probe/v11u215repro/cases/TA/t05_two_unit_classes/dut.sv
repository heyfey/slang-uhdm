// § pkgTdAliasLastWriter215 — two $unit classes zeta then alpha in one importing file (name order: zeta last)
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
class zeta;
  int q;
endclass
class alpha;
  alias_t v;
endclass
module m;
endmodule
