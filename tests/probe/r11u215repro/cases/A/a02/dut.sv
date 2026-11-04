// § pkgTdAliasLastWriter215 — an interface imports, no module does (MiniAmiq's svaunit_vpi_interface shape)
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
interface ifc;
  import p::*;
endinterface
module m;
  ifc i();
endmodule
