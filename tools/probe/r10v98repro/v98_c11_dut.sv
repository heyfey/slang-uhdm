// v98_c11 — the WINNER is a CLASS-HANDLE typedef (class_typespec, the corpus
// shape) and the winner class is otherwise UNUSED: does the patch mint
// spurious objects?
package p11v;
  class payload11v; int f; endclass
  class other11v;   int g; endclass
  class a11win98v;                       // alphabetically first, never used
    typedef payload11v ch11_t;
  endclass
  class m11base98v;
    typedef other11v ch11_t;
    function void own(ch11_t x); endfunction
  endclass
  class z11der98v extends m11base98v;
    function void hot(ch11_t x); endfunction
    function ch11_t ret(); return null; endfunction
  endclass
endpackage
module top11v;
  import p11v::*;
  z11der98v z;
  initial z = new();
endmodule
