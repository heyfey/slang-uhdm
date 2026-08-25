// r10uvm139 arm E — the ONE face this law deliberately does NOT reach: the
// `blockLocal` carve-out (`isEnumArr || namedTypeLocal`), which suppresses the
// tf-item stamp for a local declared through a NAMED typedef in a
// NON-PACKAGE-scoped subroutine.  Golden applies the tf-item rule there too
// (`vpiAutomatic:1` with no lifetime written), so these cells stay WRONG — they
// are recorded as this pass's R1, unchanged by it, and the arm exists so the
// residue is a measured artifact rather than a claim.
// Names deliberately unlike arms A-D.
typedef struct { int hob; } Ladle139_s;
typedef Ladle139_s Ladle139_t;
typedef enum {WARP139, WEFT139} shuttle139_e;

class Bellows139;
  typedef enum {EMBER139, CINDER139} glow139_e;
  typedef int reed139_t;
  class Nest139; endclass

  // paren-less class method: TF-ITEM production, and PACKAGE-scope-free, so
  // `namedTypeLocal` can fire
  function void mTd139;
    Ladle139_t   ca;
    static Ladle139_t cb;
    automatic Ladle139_t cc;
    glow139_e    cd;
    static glow139_e ce;
    reed139_t    cf;
    static reed139_t cg;
    Nest139      ch;
    static Nest139 ci;
    shuttle139_e cj[3];
    static shuttle139_e ck[3];
    cd = ce;
  endfunction
endclass

module Trestle139;
  typedef struct { int rung; } Stile139_s;
  typedef Stile139_s Stile139_t;

  // paren-less MODULE function: TF-ITEM production, not package scope
  function void mfTd139;
    Stile139_t   da;
    static Stile139_t db;
    automatic Stile139_t dc;
    Ladle139_t   dd;
    static Ladle139_t de;
    shuttle139_e df;
    static shuttle139_e dg;
    shuttle139_e dh[2];
    static shuttle139_e di;
    da = db;
  endfunction

  // paren-less MODULE task with a body io declaration: TF-ITEM production
  task mtTd139;
    input int ea;
    Stile139_t eb;
    static Stile139_t ec;
    automatic Stile139_t ed;
    eb = ec;
  endtask

  initial mtTd139(0);
endmodule
