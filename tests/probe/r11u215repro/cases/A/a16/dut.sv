// § pkgTdAliasLastWriter215 — a class typedef declared inside a class (not a package typedef): no firing
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
class holder;
  typedef p::gen#(int) hg_t;
  hg_t h;
endclass
module m;
endmodule
