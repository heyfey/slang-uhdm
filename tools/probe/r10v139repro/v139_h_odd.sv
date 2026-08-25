// r10v139 arm H — ODD MODIFIER ORDERS and exotic local types on the TF-ITEM
// face: `const static`, `var static`, `const automatic`, chandle, event,
// virtual interface handles, an enum ARRAY and a named-typedef local inside a
// PACKAGE subroutine (where the blockLocal carve-out does NOT apply), and a
// generate-block function.
interface Spindle139;
  logic tick139;
endinterface

package Wicket139;
  typedef enum {PA139, PB139} Latch139;
  typedef int Cog139;
  class Pawl139; int t139; endclass

  function void oddMods139;
    const  int      ha = 3;
    var    int      hb;
    const  static int hc = 4;
    var    static int hd;
    const  automatic int he = 5;
    static int      hf;
    automatic int   hg;
    int             hh;
    hb = ha; hd = hc; hf = 1; hg = 2; hh = 3;
  endfunction

  function void exotic139;
    chandle         ia;
    event           ib;
    static chandle  ic;
    static event    id;
    Latch139        ie[3];        // enum ARRAY in a PACKAGE tf-item
    static Latch139 if_[2];
    Cog139          ig;           // named typedef in a PACKAGE tf-item
    static Cog139   ih;
    Pawl139         ii;
    static Pawl139  ij;
    virtual Spindle139 ik;
    static virtual Spindle139 il;
    ig = 1; ih = 2;
  endfunction
endpackage

module Trammel139;
  Latch139Holder139 lh139();
  generate
    if (1) begin : gblk139
      function void genFn139;
        int      ja;
        static int jb;
        automatic int jc;
        ja = 1; jb = 2; jc = 3;
      endfunction
    end
  endgenerate
  initial gblk139.genFn139();
endmodule

module Latch139Holder139;
  import Wicket139::*;
  function void modTd139;
    Cog139     ka;          // named typedef in a MODULE tf-item (carve-out)
    static Cog139 kb;
    Latch139   kc[2];
    int        kd;
    static int ke;
    kd = 1; ke = 2;
  endfunction
  initial modTd139();
endmodule
