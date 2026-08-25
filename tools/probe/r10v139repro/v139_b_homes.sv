// r10v139 arm B — HOMES.  Same three written spellings in every home the
// brief names: a package class method (in-body AND out-of-body), a free
// package function AND task, a module task and function, a program task, an
// interface task, and a $unit function.  Both header shapes where legal.
package Sundry139;
  class Bramble139;
    int seed139;
    // in-body method, paren-less  -> TF-ITEM
    function void inNoParen139;
      int      aa;
      static int ab;
      automatic int ac;
      aa = 1; ab = 2; ac = 3;
    endfunction
    // in-body method, parened     -> BLOCK
    function void inParen139();
      int      ba;
      static int bb;
      automatic int bc;
      ba = 1; bb = 2; bc = 3;
    endfunction
    // in-body task, paren-less, NO body io  -> BLOCK (task rule)
    task inTask139;
      int      ca;
      static int cb;
      automatic int cc;
      ca = 1; cb = 2; cc = 3;
    endtask
    // in-body task with a BODY IO decl      -> TF-ITEM
    task inTaskIo139;
      input int io139;
      int      da;
      static int db;
      automatic int dc;
      da = io139; db = 2; dc = 3;
    endtask
    // out-of-body listing
    extern function void ooB139;
    extern task ooT139;
    // subroutine's OWN lifetime, both spellings
    function automatic void subAuto139;
      int      ea;
      static int eb;
      automatic int ec;
      ea = 1; eb = 2; ec = 3;
    endfunction
    static function void subStat139;
      int      fa;
      static int fb;
      automatic int fc;
      fa = 1; fb = 2; fc = 3;
    endfunction
  endclass

  function void Bramble139::ooB139;
    int      ga;
    static int gb;
    automatic int gc;
    ga = 1; gb = 2; gc = 3;
  endfunction

  task Bramble139::ooT139;
    int      ha;
    static int hb;
    automatic int hc;
    ha = 1; hb = 2; hc = 3;
  endtask

  // free package function / task
  function void freeFn139;
    int      ia;
    static int ib;
    automatic int ic;
    ia = 1; ib = 2; ic = 3;
  endfunction

  task freeTk139;
    int      ja;
    static int jb;
    automatic int jc;
    ja = 1; jb = 2; jc = 3;
  endtask

  function static void freeFnStat139;
    int      lza;
    static int lzb;
    automatic int lzc;
    lza = 1; lzb = 2; lzc = 3;
  endfunction

  function automatic void freeFnAuto139;
    int      lya;
    static int lyb;
    automatic int lyc;
    lya = 1; lyb = 2; lyc = 3;
  endfunction

  task freeTkIo139;
    output int oj139;
    int      kaa;
    static int kbb;
    automatic int kcc;
    kaa = 1; kbb = 2; kcc = 3; oj139 = kaa;
  endtask
endpackage

interface Culvert139;
  task ifTask139;
    input int q139;
    int      la;
    static int lb;
    automatic int lc;
    la = q139; lb = 2; lc = 3;
  endtask
  function void ifFn139;
    int      ma;
    static int mb;
    automatic int mc;
    ma = 1; mb = 2; mc = 3;
  endfunction
endinterface

program Turnstile139;
  task pgTask139;
    input int r139;
    int      na;
    static int nb;
    automatic int nc;
    na = r139; nb = 2; nc = 3;
  endtask
  function void pgFn139;
    int      oa;
    static int ob;
    automatic int oc;
    oa = 1; ob = 2; oc = 3;
  endfunction
  initial pgFn139();
endprogram

module Ratchet139;
  function void mdFn139;
    int      pa;
    static int pb;
    automatic int pc;
    pa = 1; pb = 2; pc = 3;
  endfunction
  task mdTask139;
    input int s139;
    int      qa;
    static int qb;
    automatic int qc;
    qa = s139; qb = 2; qc = 3;
  endtask
  task mdTaskNoIo139;
    int      ra;
    static int rb;
    automatic int rc;
    ra = 1; rb = 2; rc = 3;
  endtask
  initial mdFn139();
endmodule

// $unit function
function void unitFn139;
  int      sa;
  static int sb;
  automatic int sc;
  sa = 1; sb = 2; sc = 3;
endfunction

task unitTk139;
  input int t139;
  int      ta;
  static int tb;
  automatic int tc;
  ta = t139; tb = 2; tc = 3;
endtask

module TopB139;
  Ratchet139 r139i();
  initial unitFn139();
endmodule
