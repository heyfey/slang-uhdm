// § pkgTdAliasLastWriter215 — nested classes two levels deep as the last writer: a $unit class outer::mid::inner and a module-local class lc::inner (v11u215 residue 3: wrong on both binaries?)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class gen #(type T=int); T v; endclass
  typedef gen#(int) g_int_t;
  class c;
    function void set(alias_t v, g_int_t w); endfunction
  endclass
endpackage
import p::*;
class outer;
  class mid;
    class inner;
      alias_t z;
    endclass
  endclass
endclass
module m;
  import p::*;
  class lc;
    class inner;
      int z;
    endclass
  endclass
endmodule
