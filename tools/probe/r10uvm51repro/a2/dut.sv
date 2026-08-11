// r10uvm51 arm a2 — the REACH cells for the type-parameter index law.
// a1 measured the CLASS-PROPERTY site (the corpus shape).  There are five
// copies of the associative-index rule in the emitter
// (`grep -n sharedAliasTs src/`); a2 asks each remaining one whether golden
// suppresses there too, plus the INNER-dimension marker form.
//   1 MODULE-scope `parameter type` index          (TypeEmit array_var site)
//   2 PACKAGE-scope `parameter type` index         (emitPkgArrayVar site)
//   3 SUBROUTINE-LOCAL, index = class type param   (TaskFuncEmit site)
//   4 INNER dimension is the type parameter        (marker-constant form)
//   5 OUTER type param + INNER concrete            (marker-constant form)
//   6 concrete controls beside every one of them
package p51b;
  parameter type PKEY = int;
  typedef int myint51b;
  int pk_pool[PKEY];        // 2: package-scope, index is a parameter type
  int pk_ctl[string];       // 6: control at the same site

  class gq51 #(type KEY = int, type T = int);
    T ii_pool[string][KEY];  // 4: INNER dim is the type parameter
    T oo_pool[KEY][string];  // 5: OUTER type param, inner concrete
    T cc_pool[string][myint51b];  // 6: control, both concrete

    function void f51();
      T loc_pool[KEY];       // 3: subroutine-local, index is the type param
      int loc_ctl[string];   // 6: control at the same site
      loc_pool = loc_pool;
      loc_ctl = loc_ctl;
    endfunction
  endclass
endpackage

module a2_top;
  parameter type MKEY = int;
  import p51b::*;
  int mk_pool[MKEY];        // 1: module-scope, index is a parameter type
  int mk_ctl[string];       // 6: control at the same site
  gq51 #(int, int) q1;
endmodule
