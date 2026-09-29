// § pkgTdAliasLastWriter215 — two importing packages, source order zq then aq (name order the reverse)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
package zq;
  import p::*;
endpackage
package aq;
  import p::*;
endpackage
module m;
endmodule
