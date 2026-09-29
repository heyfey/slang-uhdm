// § pkgTdAliasLastWriter215 — an interface-local class and a module importing (interfaces before modules)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
interface ifc;
  import p::*;
  class ic;
    int z;
  endclass
endinterface
module m;
  import p::*;
  ifc u();
endmodule
