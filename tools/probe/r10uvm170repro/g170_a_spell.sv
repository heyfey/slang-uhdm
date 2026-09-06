// r10uvm170 arm A — THE SPELLING AXIS, at the corpus's own site (a cast target
// inside a package subroutine whose `export "DPI-C"` is written ABOVE it).
// Every cell is written twice: once in the EXPORTED subroutine and once in a
// NON-exported twin whose body is byte-for-byte the same, so each row carries
// its own control.
package fa170;                    // the FOREIGN package
  typedef enum bit [1:0] { FA0, FA1 } fa_t;
  typedef enum bit [2:0] { FB0, FB1 } fb_t;
  typedef struct packed { bit [3:0] q; } fs_t;
endpackage

package pa170;
  import fa170::*;                // wildcard
  import fa170::fb_t;             // explicit
  typedef enum bit [1:0] { A0, A1 } ea_t;      // same-package enum
  typedef struct packed { bit [3:0] a; } sa_t; // same-package struct
  typedef logic [7:0] la_t;                    // same-package vector alias

  function void snk_a(int q);
  endfunction

  export "DPI-C" function fx_a;
  function void fx_a(int s);
    snk_a(int'(ea_t'(s)));          // a01 bare, same package, enum
    snk_a(int'(sa_t'(s)));          // a02 bare, same package, struct
    snk_a(int'(la_t'(s)));          // a03 bare, same package, vector alias
    snk_a(int'(pa170::ea_t'(s)));   // a04 scoped, same package
    snk_a(int'(fa_t'(s)));          // a05 bare, wildcard-imported
    snk_a(int'(fb_t'(s)));          // a06 bare, explicitly imported
    snk_a(int'(fa170::fa_t'(s)));   // a07 scoped, foreign package
    snk_a(int'(fa170::fs_t'(s)));   // a08 scoped foreign struct
    snk_a(int'(byte'(s)));          // a09 builtin keyword target
    snk_a(int'(4'(s)));             // a10 size cast (literal width)
  endfunction

  function void fy_a(int s);        // the NON-exported twin — every cell a control
    snk_a(int'(ea_t'(s)));          // b01
    snk_a(int'(sa_t'(s)));          // b02
    snk_a(int'(la_t'(s)));          // b03
    snk_a(int'(pa170::ea_t'(s)));   // b04
    snk_a(int'(fa_t'(s)));          // b05
    snk_a(int'(fb_t'(s)));          // b06
    snk_a(int'(fa170::fa_t'(s)));   // b07
    snk_a(int'(fa170::fs_t'(s)));   // b08
    snk_a(int'(byte'(s)));          // b09
    snk_a(int'(4'(s)));             // b10
  endfunction
endpackage

module top_a170;
  initial pa170::fy_a(1);
endmodule
