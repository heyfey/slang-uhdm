// § pkgTdAliasLastWriter215 — two root files: the package and a module in f1, a $unit import with a class and a module in f2
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module zm;
  import p::*;
endmodule
