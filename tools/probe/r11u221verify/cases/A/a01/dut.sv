// § pkgTdAliasLastWriter215 — every writer kind with names in reverse kind order: module aa, interface zz_if, program mm_prg, an importing package qq (golden: the module last)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
package qq;
  import p::*;
  parameter int QN = 1;
endpackage
program mm_prg;
  import p::*;
endprogram
interface zz_if;
  import p::*;
endinterface
module aa;
  import p::*;
  zz_if u_if();
  mm_prg u_prg();
endmodule
