// r10v140 arm U — the law's interaction with the OTHER committed typedef laws:
// a cast target (uvm123 clone law), a class typedef clone (uvm112), an enum
// base range (uvm114), a returned bare enumerator (uvm138); plus a base
// declared INSIDE a class with the alias in the package, and two SIBLING
// classes of one package returning the same alias.
package Loom_pkg;
  typedef enum bit [4:0] { WARP_A = 1, WEFT_B = 2, SHED_C = 4 } threadKind;
  typedef threadKind ThreadKind_e;
  typedef struct packed { bit [6:0] tension; } spoolWord;
  typedef spoolWord SpoolWord_s;

  class Shuttle;
    typedef enum bit [2:0] { HOOK_UP = 1, HOOK_DN = 2 } hookState;
    ThreadKind_e held;
    function ThreadKind_e castThenReturn(int raw);
      ThreadKind_e c;
      c = ThreadKind_e'(raw);          // cast target names the ALIAS
      return c;
    endfunction
    function threadKind castBaseReturn(int raw);
      threadKind c;
      c = threadKind'(raw);            // cast target names the BASE
      return c;
    endfunction
    function ThreadKind_e bareEnumerator(); return WARP_A; endfunction
    function SpoolWord_s spoolOut(); SpoolWord_s s; return s; endfunction
    function hookState innerHook(); return HOOK_UP; endfunction
  endclass

  // (a package alias of a CLASS-scope enum is rejected by Surelog itself —
  //  CP0317 "Undefined type" — so this arm carries no such face.)

  class Reed;                                // sibling class, same package
    function ThreadKind_e reedThread(); return WEFT_B; endfunction
    function SpoolWord_s reedSpool(); SpoolWord_s s; return s; endfunction
  endclass

  class Heddle #(type WT = ThreadKind_e);    // parameterised, specialised below
    WT carried;
    function WT heddleOut(); return carried; endfunction
    function ThreadKind_e heddleFixed(); return SHED_C; endfunction
  endclass
endpackage

module loom_top;
  import Loom_pkg::*;
  Loom_pkg::Shuttle sh;
  Loom_pkg::Reed rd;
  Loom_pkg::Heddle #(Loom_pkg::ThreadKind_e) hd_alias;
  Loom_pkg::Heddle #(Loom_pkg::threadKind)   hd_base;
  Loom_pkg::Heddle #(Loom_pkg::SpoolWord_s)  hd_word;
  Loom_pkg::ThreadKind_e tk;
  initial tk = Loom_pkg::WARP_A;
endmodule
