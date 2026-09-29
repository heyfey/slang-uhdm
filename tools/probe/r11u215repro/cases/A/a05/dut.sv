// § pkgTdAliasLastWriter215 — a program, an interface and a module import: the module wins
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
program pg;
  import p::*;
endprogram
interface ifc;
  import p::*;
endinterface
module m;
  import p::*;
  ifc i();
endmodule
