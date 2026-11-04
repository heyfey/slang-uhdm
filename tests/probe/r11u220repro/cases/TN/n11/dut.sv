// r11u220 decode (no law): pass 215 residue, nested classes as the last typedef writer (UhdmWriter writeClass, ClassMap name order); the stamp is overwritten by the sister drain
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
  class inner;
    int z;
  endclass
endclass
