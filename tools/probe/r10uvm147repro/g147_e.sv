// r10uvm147 arm E — RECEIVER SHAPE x HOME x INSTANCE COUNT, plus the
// § builtinRecvMultiDimStepIsBitSelectChain14 CONTROL (a BUILTIN-METHOD
// receiver, whose bit-select chain must stay exactly as buvm14 left it) and
// the § hpTrailSelIdxDecompiled89 / § hpMidSelIdxAtPath79 controls.
package q147e;

  class ce147 #(int W = 64);
    logic [W-1:0] dyn[];        // dynamic array
    logic [W-1:0] que[$];       // queue
    logic [W-1:0] fix[4];       // fixed unpacked
    logic [W-1:0] asc[string];  // associative
    logic [3:0][15:0] pkd;      // packed 2-dim
    logic [W-1:0] pk;           // packed scalar
    int           ix[8];
  endclass

  typedef struct { logic [63:0] mem[4]; } sm147_t;

  class base147;
    // out-of-body method declared here, defined below
    extern function void oob(ce147 fa, int lo, int i);
    function void inbody(ce147 fa, int lo, int i);
      logic [7:0] o;
      o = fa.dyn[lo][8*i +: 8];   // e01 dynamic array,   in-body method
      o = fa.que[lo][8*i +: 8];   // e02 queue
      o = fa.fix[lo][8*i +: 8];   // e03 fixed unpacked
      o = fa.pkd[lo][8*i +: 8];   // e04 packed 2-dim
      o = fa.asc["k"][8*i +: 8];  // e05 associative
    endfunction
    task intask(ce147 fa, int lo, int i);
      logic [7:0] o;
      o = fa.dyn[lo][8*i +: 8];   // e06 in a TASK
    endtask
    function void withstruct(sm147_t sm, int lo, int i);
      logic [7:0] o;
      o = sm.mem[lo][8*i +: 8];   // e07 STRUCT-member receiver
    endfunction
    // § builtinRecvMultiDimStepIsBitSelectChain14 CONTROL — a BUILTIN METHOD
    // on a multi-dim receiver.  buvm14 owns this shape; it must not move.
    function void builtin14(ce147 fa, int lo, int i);
      int n;
      logic [63:0] q2[int][int];
      n = fa.dyn.size();          // e08 builtin on a plain member
      n = fa.que.size();          // e09 builtin on a queue member
      if (q2.exists(lo)) n = 1;   // e10 builtin on a local assoc
      n = fa.ix.sum();            // e11 builtin with a reduction
    endfunction
    // § hpTrailSelIdxDecompiled89 CONTROL — a TRAILING bit-select whose index
    // decompileHelper has no row for, in LVALUE and rvalue position.
    function void trail89(ce147 fa, int lo, int i);
      logic [63:0] o64;
      o64 = fa.dyn[fa.ix[i]];     // e12 rvalue, nested-select index
      fa.dyn[fa.ix[i]] = 64'h1;   // e13 LVALUE, nested-select index
      o64 = fa.dyn[lo];           // e14 rvalue, ref_obj index (control)
    endfunction
  endclass

  function void base147::oob(ce147 fa, int lo, int i);
    logic [7:0] o;
    o = fa.dyn[lo][8*i +: 8];     // e15 OUT-OF-BODY method
    o = fa.fix[lo][i*8 +: 8];     // e16
  endfunction

  function automatic void free147(ce147 fa, int lo, int i);
    logic [7:0] o;
    o = fa.dyn[lo][8*i +: 8];     // e17 PACKAGE FREE function
  endfunction
endpackage

module m147e;
  import q147e::*;
  ce147 h1, h2, h3;
  sm147_t sm;
  int lo, i;
  logic [7:0] o;
  initial begin
    o = h1.dyn[lo][8*i +: 8];     // e18 module scope, instance 1
    o = h2.dyn[lo][8*i +: 8];     // e19 instance 2
    o = h3.dyn[lo][8*i +: 8];     // e20 instance 3
    o = sm.mem[lo][8*i +: 8];     // e21 module struct member
  end
  // three instances of a class-typed handle used in three separate processes
  always_comb o = h1.fix[lo][8*i +: 8];   // e22
  initial     o = h2.fix[lo][8*i +: 8];   // e23
  final       o = h3.fix[lo][8*i +: 8];   // e24
endmodule
