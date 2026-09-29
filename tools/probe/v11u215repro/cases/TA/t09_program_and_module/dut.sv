// § pkgTdAliasLastWriter215 — a program and a module importing (modules after programs)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
program pr;
  import p::*;
endprogram
module m;
  import p::*;
endmodule
