// r10uvm139 arm A — the HOMES a subroutine local can live in, each carrying
// the three written lifetimes (none / static / automatic) on the VARIABLE, and
// the three spellings on the SUBROUTINE where the LRM allows them.
// Names are deliberately unlike every other arm's.
package Quarry139;

  class Chisel139;
    // in-body class method, paren-less  -> TF-ITEM production
    function void inbNoParen139;
      string  ka;
      static string kb;
      automatic string kc;
      ka = kb;
    endfunction
    // in-body class method, parenthesised -> BLOCK production
    function void inbParen139();
      string  kd;
      static string ke;
      automatic string kf;
      kd = ke;
    endfunction
    // in-body class TASK, paren-less
    task inbTask139;
      string  kg;
      static string kh;
      automatic string ki;
      kg = kh;
    endtask
    // in-body class task WITH a body io declaration -> TF-ITEM production
    task inbTaskIo139;
      input int kj;
      string  kk;
      static string kl;
      automatic string km;
      kk = kl;
    endtask
    // written `function automatic` — the SUBROUTINE lifetime, which the
    // tf-item rule does NOT read
    function automatic void inbAutoLife139;
      string  kn;
      static string ko;
      automatic string kp;
      kn = ko;
    endfunction
    // STATIC class method
    static function void inbStatMeth139;
      string  kq;
      static string kr;
      automatic string ks;
      kq = kr;
    endfunction
    // out-of-body method declared here, defined below
    extern function void oobNoParen139;
    extern function void oobParen139();
  endclass

  function void Chisel139::oobNoParen139;
    string  la;
    static string lb;
    automatic string lc;
    la = lb;
  endfunction

  function void Chisel139::oobParen139();
    string  ld;
    static string le;
    automatic string lf;
    ld = le;
  endfunction

  // package free function, both header shapes
  function void pkgNoParen139;
    string  ma;
    static string mb;
    automatic string mc;
    ma = mb;
  endfunction

  function void pkgParen139();
    string  md;
    static string me;
    automatic string mf;
    md = me;
  endfunction

  // package free function with an explicit STATIC lifetime
  function static void pkgStatLife139;
    string  mg;
    static string mh;
    automatic string mi;
    mg = mh;
  endfunction

  // package task
  task pkgTask139;
    string  mj;
    static string mk;
    automatic string ml;
    mj = mk;
  endtask

  task pkgTaskIo139;
    input int mm;
    string  mn;
    static string mo;
    automatic string mp;
    mn = mo;
  endtask

endpackage

interface Sluice139;
  function void ifcNoParen139;
    string  na;
    static string nb;
    automatic string nc;
    na = nb;
  endfunction
  function void ifcParen139();
    string  nd;
    static string ne;
    automatic string nf;
    nd = ne;
  endfunction
endinterface

program Weir139;
  function void prgNoParen139;
    string  oa;
    static string ob;
    automatic string oc;
    oa = ob;
  endfunction
  initial begin : prgBlk139
    string  od;
    static string oe;
    automatic string of;
    od = oe;
  end
endprogram

module Gantry139;
  function void modNoParen139;
    string  pa;
    static string pb;
    automatic string pc;
    pa = pb;
  endfunction
  function void modParen139();
    string  pd;
    static string pe;
    automatic string pf;
    pd = pe;
  endfunction
  task modTask139;
    string  pg;
    static string ph;
    automatic string pi;
    pg = ph;
  endtask
  task modTaskIo139;
    input int pj;
    string  pk;
    static string pl;
    automatic string pm;
    pk = pl;
  endtask

  initial begin : modBlk139
    string  qa;
    static string qb;
    automatic string qc;
    qa = qb;
  end

  always @(*) begin : modAlw139
    string  qd;
    static string qe;
    automatic string qf;
    qd = qe;
  end

  initial fork : modFork139
    begin
      string  qg;
      static string qh;
      automatic string qi;
      qg = qh;
    end
  join_none

  // a subroutine inside a GENERATE block
  if (1) begin : modGen139
    function void genNoParen139;
      string  ra;
      static string rb;
      automatic string rc;
      ra = rb;
    endfunction
  end

  Sluice139 sl139();
endmodule
