// § pkgTdAliasLastWriter215 — a module importing only the base enum item p::e_t (not a writer of alias_t), another importing the alias item
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module m1;
  import p::e_t;
endmodule
module m0;
  import p::alias_t;
endmodule
