// § pkgTdAliasLastWriter215 — the alias target lives in another package (typedef r::e_t alias_t in p)
package r;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package p;
  typedef r::e_t alias_t;
  class c;
    function void set(alias_t v); endfunction
  endclass
endpackage
module m;
  import p::*;
endmodule
