// § pkgTdAliasLastWriter215 — two module-local classes zc then ac in an importing module (the name-last class writes)
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
  class zc; int a; endclass
  class ac; int b; endclass
endmodule
