// r10uvm51 arm a1 — the ASSOCIATIVE-ARRAY INDEX TYPESPEC grid.
// Corpus witness: uvm-1.2 base/uvm_pool.svh:42 `protected T pool[KEY];` in
// `class uvm_pool #(type KEY=int, T=uvm_void)`.  Cells, in order:
//   1 index = TYPE PARAMETER WITH a default        (the corpus shape)
//   2 index = CONCRETE keyword type, same class    (must-not-move control)
//   3 element = type parameter, QUEUE              (element-vs-index cell)
//   4 element = type parameter, DYNAMIC array      (element-vs-index cell)
//   5 index = TYPE PARAMETER *WITH* a default (RELABELLED AT INTEGRATION -- the
//     class below is `#(type KEY2 = int)`, so it HAS one. The without-default cell
//     the brief asked for was NEVER MEASURED here; see the README correction.)
//   6 index = concrete / typedef'd / keyword, PLAIN class (must-not-move)
//   7 packed range bound that is a VALUE parameter (family-width probe)
package p51;

  typedef int myint51;

  // 1/2/3/4 — a GENERIC class, both a type-parameter index and a concrete one.
  class gp51 #(type KEY = int, type T = int);
    T tp_pool[KEY];          // 1: index IS the type parameter KEY
    int c_pool[string];      // 2: CONTROL, concrete index in the SAME class
    T tq[$];                 // 3: element is a type parameter, queue
    T tdy[];                 // 4: element is a type parameter, dynamic array
    T tp2_pool[myint51];     // 2b: type-param ELEMENT, TYPEDEF index
  endclass

  // 5 -- type parameter WITH a default (see the relabel at the top of this file).
  class gnd51 #(type KEY2 = int);
    int nd_pool[KEY2];
  endclass

  // 6 — PLAIN class, the must-not-move controls.
  class pc51;
    int pc_pool[string];
    int pt_pool[myint51];
    int pi_pool[int];
  endclass

  // 7 — packed range bound that is a VALUE parameter.
  class vp51 #(int W = 8);
    logic [W-1:0] vec;
    int vw_pool[logic [W-1:0]];
  endclass

endpackage

module a1_top;
  import p51::*;
  gp51 #(string, int) g1;
  gnd51 #(int) g2;
  pc51 p1;
  vp51 #(8) v1;
endmodule
