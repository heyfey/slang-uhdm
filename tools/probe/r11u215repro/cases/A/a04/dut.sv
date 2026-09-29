// § pkgTdAliasLastWriter215 — two modules import: the name-last module wins (z_mod declared first)
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
module z_mod;
  import p::*;
endmodule
module a_mod;
  import p::*;
  z_mod u();
endmodule
