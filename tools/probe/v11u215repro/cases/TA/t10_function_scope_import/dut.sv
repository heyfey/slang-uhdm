// § pkgTdAliasLastWriter215 — a module whose only import sits inside a function body
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module m;
  function automatic int f();
    import p::*;
    return 0;
  endfunction
endmodule
