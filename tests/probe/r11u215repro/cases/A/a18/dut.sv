// § pkgImportEnumCloneLastWriter215 — a plain enum with an importing package (pkgImportEnumCloneLastWriter215: q::p::e_t)
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
package q;
  import p::*;
  class d; e_t z; endclass
endpackage
module m;
endmodule
