// r10v139 arm F — the blockLocal CARVE-OUT face (R1) and the enum-array face,
// in a NON-package subroutine.  This pass deliberately does not fire here;
// the arm exists to prove pristine == patched on it.
typedef enum {AH139, BH139} Kite139;
typedef int Reel139;

module Halyard139;
  function void carveFn139;
    Reel139   ca;              // named typedef, non-package scope
    Kite139   cb[3];           // packed/unpacked array of enum
    static Reel139 cc;
    automatic Reel139 cd;
    Reel139   ce = 4;
    ca = 1; cc = 2; cd = 3;
  endfunction
  task carveTk139;
    input int di;
    Reel139   da;
    Kite139   db[2];
    static Reel139 dc;
    da = di; dc = di;
  endtask
  initial carveFn139();
endmodule
