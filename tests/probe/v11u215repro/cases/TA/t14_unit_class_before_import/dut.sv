// § pkgTdAliasLastWriter215 — a $unit class declared BEFORE the file's $unit import (zcls sorts after the module's writer)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module m;
  import p::*;
endmodule
class zcls;
  int q;
endclass
import p::*;
class acls;
  int r;
endclass
