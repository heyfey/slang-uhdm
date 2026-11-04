// § pkgTdAliasLastWriter215 — the class specialization alias used as a module variable type, two modules importing
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module b;
  import p::*;
  g_int_t h;
endmodule
module a;
  import p::*;
  g_int_t h2;
  b u();
endmodule
