// § pkgTdAliasLastWriter215 — the typedefs in an included file of the package, a module importing
package p;
  `include "td.svh"
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
module m;
  import p::*;
endmodule
