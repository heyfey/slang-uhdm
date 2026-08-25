// r10v143 arm F — THE FORMAL-FACE MATRIX on the shape our emitter actually
// binds (`if (tbl[<idx>].tally == 0)`), in-body and out-of-body twins.
// LHS IS ALWAYS GOLDEN.  Names deliberately unlike UVM's and unlike arm A's.
package pkF143v;

  class Grain;
    int tally;
    int gauge;
  endclass

  typedef enum int { FG_NIL = 0, FG_ONE = 1 } fgrade_e;
  typedef struct { int lo; int hi; } fpair_t;
  parameter int FP_SLOT = 2;

  function automatic int fseed();
    return 3;
  endfunction

  // ---------------- IN-BODY class (the gated side) ---------------------
  class Sieve;
    Grain byInt[int];
    Grain byHnd[Grain];
    Grain byStr[string];
    Grain byEnm[fgrade_e];
    Grain byPair[fpair_t];
    Grain queueOf[$];
    Grain fixedOf[6];
    Grain dynOf[];
    int   mote;

    // default position -------------------------------------------------
    task f01_firstDefault(int a = 0, int b, int c);
      if (byInt[a].tally == 0) $display("f01");
    endtask
    task f02_midDefault(int a, int b = 1, int c);
      if (byInt[b].tally == 0) $display("f02");
    endtask
    task f03_lastDefault(int a, int b, int c = 2);
      if (byInt[c].tally == 0) $display("f03");
    endtask
    task f04_allDefault(int a = 0, int b = 1, int c = 2);
      if (byInt[a].tally == byInt[b].gauge + byInt[c].tally) $display("f04");
    endtask

    // what the default IS ----------------------------------------------
    task f05_defNull(Grain g = null);
      if (byHnd[g].tally == 0) $display("f05");
    endtask
    task f06_defLit(int s = 7);
      if (byInt[s].tally == 0) $display("f06");
    endtask
    task f07_defParam(int s = FP_SLOT);
      if (byInt[s].tally == 0) $display("f07");
    endtask
    task f08_defCall(int s = fseed());
      if (byInt[s].tally == 0) $display("f08");
    endtask
    task f09_defConcat(int s = {8'd1, 8'd2, 16'd3});
      if (byInt[s].tally == 0) $display("f09");
    endtask
    task f10_defStr(string s = "hay");
      if (byStr[s].tally == 0) $display("f10");
    endtask

    // direction ----------------------------------------------------------
    task f11_input(input int s);
      if (byInt[s].tally == 0) $display("f11");
    endtask
    task f12_output(output int s);
      s = 0;
      if (byInt[s].tally == 0) $display("f12");
    endtask
    task f13_inout(inout int s);
      if (byInt[s].tally == 0) $display("f13");
    endtask
    task f14_ref(ref int s);
      if (byInt[s].tally == 0) $display("f14");
    endtask

    // the TYPE of the indexing formal --------------------------------------
    task f15_handle(Grain g = null);
      if (byHnd[g].tally == 0) $display("f15");
    endtask
    task f16_enum(fgrade_e e = FG_ONE);
      if (byEnm[e].tally == 0) $display("f16");
    endtask
    task f17_struct(fpair_t p);
      if (byPair[p].tally == 0) $display("f17");
    endtask
    task f18_string(string s = "sil");
      if (byStr[s].tally == 0) $display("f18");
    endtask
    task f19_queue(int q[$]);
      if (queueOf[q[0]].tally == 0) $display("f19");
    endtask
    task f20_unpacked(int u[4]);
      if (fixedOf[u[1]].tally == 0) $display("f20");
    endtask
    task f21_dynarr(int d[]);
      if (dynOf[d[2]].tally == 0) $display("f21");
    endtask

    // function (not task) with the same body ------------------------------
    function int f22_fn(int s = 1);
      int r = 0;
      if (byInt[s].tally == 0) r = 1;
      return r;
    endfunction

    // static / virtual / constructor ----------------------------------------
    static Grain stat[int];
    static task f23_static(int s = 1);
      if (stat[s].tally == 0) $display("f23");
    endtask
    virtual task f24_virtual(int s = 9);
      if (byInt[s].tally == 0) $display("f24");
    endtask
    function new(int s = 4, Grain g = null);
      if (byInt[s].tally == 0) mote = 1;
      if (byHnd[g].gauge == 0) mote = 2;
    endfunction

    // a body LOCAL, a class PROPERTY and a LITERAL (non-formal indices) -------
    task f25_local();
      int s;
      s = 1;
      if (byInt[s].tally == 0) $display("f25");
    endtask
    task f26_prop();
      if (byInt[mote].tally == 0) $display("f26");
    endtask
    task f27_literal();
      if (byInt[5].tally == 0) $display("f27");
    endtask
    // subtree faces the depth-1 key cannot see -------------------------------
    task f28_op(int s = 1);
      if (byInt[s + mote].tally == 0) $display("f28");
    endtask
    task f29_call(int s = 1);
      if (byInt[f22_fn(s)].tally == 0) $display("f29");
    endtask
    task f30_nested(int s = 1, int v[8] = '{default:0});
      if (byInt[v[s]].tally == 0) $display("f30");
    endtask
    task f31_member(fpair_t p);
      if (byInt[p.lo].tally == 0) $display("f31");
    endtask
    task f32_hpidx(Grain g = null);
      if (byInt[g.tally].gauge == 0) $display("f32");
    endtask
  endclass

  class SieveKid extends Sieve;
    virtual task f24_virtual(int s = 9);      // default REPEATED in the override
      if (byInt[s].gauge == 0) $display("kid");
    endtask
  endclass

  // ---------------- OUT-OF-BODY twin (the ungated side) -------------------
  class Riddle;
    Grain byInt[int];
    Grain byHnd[Grain];
    Grain byStr[string];
    int   mote;
    int   vec[8];
    extern task r01_firstDefault(int a = 0, int b, int c);
    extern task r05_defNull(Grain g = null);
    extern task r07_defParam(int s = FP_SLOT);
    extern task r12_output(output int s);
    extern task r14_ref(ref int s);
    extern task r18_string(string s = "sil");
    extern task r25_local();
    extern task r26_prop();
    extern task r28_op(int s = 1);
    extern task r30_nested(int s = 1);
    extern function new(int s = 4);
    extern virtual task r24_virtual(int s = 9);
  endclass
  task Riddle::r01_firstDefault(int a = 0, int b, int c);
    if (byInt[a].tally == 0) $display("r01");
  endtask
  task Riddle::r05_defNull(Grain g = null);
    if (byHnd[g].tally == 0) $display("r05");
  endtask
  task Riddle::r07_defParam(int s = FP_SLOT);
    if (byInt[s].tally == 0) $display("r07");
  endtask
  task Riddle::r12_output(output int s);
    s = 0;
    if (byInt[s].tally == 0) $display("r12");
  endtask
  task Riddle::r14_ref(ref int s);
    if (byInt[s].tally == 0) $display("r14");
  endtask
  task Riddle::r18_string(string s = "sil");
    if (byStr[s].tally == 0) $display("r18");
  endtask
  task Riddle::r25_local();
    int s;
    s = 1;
    if (byInt[s].tally == 0) $display("r25");
  endtask
  task Riddle::r26_prop();
    if (byInt[mote].tally == 0) $display("r26");
  endtask
  task Riddle::r28_op(int s = 1);
    if (byInt[s + mote].tally == 0) $display("r28");
  endtask
  task Riddle::r30_nested(int s = 1);
    if (byInt[vec[s]].tally == 0) $display("r30");
  endtask
  function Riddle::new(int s = 4);
    if (byInt[s].tally == 0) mote = 1;
  endfunction
  task Riddle::r24_virtual(int s = 9);
    if (byInt[s].tally == 0) $display("r24");
  endtask

  // ---------------- free package subroutines (drained) ---------------------
  Grain pkgTbl[int];
  task pk01(int s = 0);
    if (pkgTbl[s].tally == 0) $display("pk01");
  endtask
  function int pk02(int s = 0);
    int r = 0;
    if (pkgTbl[s].tally == 0) r = 1;
    return r;
  endfunction
endpackage

module topF143v;
  import pkF143v::*;
  Sieve  sv;
  Riddle rd;
  int    n;
  initial begin
    sv = new(); rd = new();
    sv.f01_firstDefault(.b(1), .c(2));
    rd.r01_firstDefault(.b(1), .c(2));
    pk01();
    n = pk02();
  end
endmodule
