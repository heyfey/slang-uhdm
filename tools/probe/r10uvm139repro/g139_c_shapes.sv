// r10uvm139 arm C — the SHAPES of the declaration itself: multi-declarator
// lists, `const`/`var` modifiers, nested `begin` blocks INSIDE a tf-item
// subroutine (where the OTHER rule applies), `task automatic`, and a
// declaration whose lifetime keyword sits on a subroutine that also has io.
// Names deliberately unlike arms A and B.
package Loom139;

  typedef enum {WARP139, WEFT139} shuttle139_e;

  class Bobbin139;
    int thread;
  endclass

  // multi-declarator lists under the TF-ITEM production
  function void tfMulti139;
    int         w1, w2;
    static int  w3, w4;
    automatic int w5, w6;
    int         w7 = 1, w8 = 2;
    static int  w9 = 1, wa = 2;
    string      wb, wc;
    static string wd, we;
    w1 = w3;
  endfunction

  // the same lists under the BLOCK production
  function void blkMulti139();
    int         x1, x2;
    static int  x3, x4;
    automatic int x5, x6;
    int         x7 = 1, x8 = 2;
    static int  x9 = 1, xa = 2;
    x1 = x3;
  endfunction

  // `const` and `var` modifiers, both productions
  function void tfConstVar139;
    const int   y1 = 3;
    var int     y2;
    var automatic int y3;
    int         y4;
    y4 = y2;
  endfunction

  function void blkConstVar139();
    const int   z1 = 3;
    var int     z2;
    var automatic int z3;
    int         z4;
    z4 = z2;
  endfunction

  // a TF-ITEM subroutine whose BODY also opens nested blocks: the block-local
  // declarations follow § blockDeclAutomaticIsWrittenKw80, NOT this law.
  function void tfNested139;
    int         aa;
    static int  ab;
    aa = ab;
    begin : inner139
      int       ac;
      static int ad;
      automatic int ae;
      ac = ad;
    end
    for (int af = 0; af < 2; af++) begin : loop139
      int       ag;
      static int ah;
      automatic int ai;
      ag = ah;
    end
  endfunction

  // `task automatic` / `task static`: the SUBROUTINE lifetime, which the
  // tf-item rule does not read
  task automatic tskAutoLife139;
    int         ba;
    static int  bb;
    automatic int bc;
    ba = bb;
  endtask

  task static tskStatLife139;
    int         bd;
    static int  be;
    automatic int bf;
    bd = be;
  endtask

  // a paren-less function whose declaration section mixes io-style and
  // block-item declarations
  task tskMixIo139;
    input  int ca;
    output int cb;
    int        cc;
    static int cd;
    automatic int ce;
    cb = cc + cd + ce + ca;
  endtask

  // arrays and handles with initialisers, tf-item face
  function void tfInit139;
    Bobbin139   da = null;
    static Bobbin139 db = null;
    shuttle139_e dc = WARP139;
    static shuttle139_e dd = WARP139;
    int         de[2] = '{0, 0};
    static int  df[2] = '{0, 0};
    dc = dd;
  endfunction

endpackage
