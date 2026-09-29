// § pkgTdAliasLastWriter215 — $unit typedefs: a $unit alias of the package alias and a $unit import beside a module and a $unit class
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
typedef alias_t unit_alias_t;
typedef p::g_int_t unit_g_t;
class uc;
  unit_alias_t ua;
  unit_g_t ug;
endclass
module m;
  unit_alias_t v;
endmodule
