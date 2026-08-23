// r10uvm103 arm a1 — DOTTED METHOD CALLS: 2 / 3 / 4 components, statement vs
// expression, class in-body / out-of-body / package / module, void function vs
// task carrier.  MEASUREMENT ONLY.  Names vary in length, case and digits so no
// cell can confirm itself by shape.
package Pk103;

  class Leaf103;
    int vv;
    function int  lfun(int kk);  return kk + vv; endfunction
    function void lvoid(int kk); vv = kk;        endfunction
    function void lv0();         vv = 0;         endfunction
    task          ltask(int kk); vv = kk;        endtask
  endclass

  class Deep103;
    Leaf103 dleaf;
    function new(); dleaf = new(); endfunction
  endclass

  class Mid103;
    Leaf103 one;
    Deep103 dp;
    Leaf103 arr[4];
    function new();
      one = new();
      dp = new();
      foreach (arr[i]) arr[i] = new();
    endfunction
    function int  mfun(int kk);  return kk;      endfunction
    function void mvoid(int kk); one.vv = kk;    endfunction
  endclass

  class Base103;
    Mid103 bm;
    function new(); bm = new(); endfunction
  endclass

  class Top103 extends Base103;
    Mid103 md;
    Mid103 mq[4];
    Leaf103 lz;
    int rr;

    function new();
      super.new();
      md = new();
      lz = new();
      foreach (mq[i]) mq[i] = new();
    endfunction

    // ---- STATEMENT position, void functions ----
    function void S2();   lz.lvoid(11);              endfunction
    function void S3();   md.one.lvoid(22);          endfunction
    function void S4();   md.dp.dleaf.lvoid(33);     endfunction
    function void S3i();  mq[0].one.lvoid(44);       endfunction
    function void S3j();  md.arr[1].lvoid(55);       endfunction
    function void S3t();  this.md.one.lvoid(66);     endfunction
    function void S3s();  super.bm.one.lvoid(77);    endfunction
    function void S3n();  md.one.lvoid(lz.lfun(88)); endfunction
    function void S3z();  md.one.lv0();              endfunction
    function void S2z();  lz.lv0();                  endfunction
    function void S3v();  void'(md.one.lfun(99));    endfunction

    // ---- STATEMENT position inside a TASK, task carrier ----
    task T2();  lz.ltask(110);            endtask
    task T3();  md.one.ltask(111);        endtask
    task T4();  md.dp.dleaf.ltask(112);   endtask
    task T3f(); md.one.lvoid(113);        endtask

    // ---- EXPRESSION position ----
    function int  E2();   return lz.lfun(122);              endfunction
    function int  E3();   return md.one.lfun(133);          endfunction
    function int  E4();   return md.dp.dleaf.lfun(144);     endfunction
    function void E3a();  rr = md.one.lfun(155);            endfunction
    function void E3c();  if (md.one.lfun(166) > 0) rr = 1; endfunction
    function void E3g();  rr = lz.lfun(md.one.lfun(177));   endfunction
    function void E3i();  rr = mq[2].one.lfun(178);         endfunction
  endclass

  // ---- OUT-OF-BODY ----
  class Oob103;
    Mid103 om;
    int qq;
    extern function void OB2();
    extern function void OB3();
    extern function void OB4();
    extern function int  OBE3();
    function new(); om = new(); endfunction
  endclass
  function void Oob103::OB2();  om.mvoid(187);            endfunction
  function void Oob103::OB3();  om.one.lvoid(188);        endfunction
  function void Oob103::OB4();  om.dp.dleaf.lvoid(189);   endfunction
  function int  Oob103::OBE3(); return om.one.lfun(199);  endfunction

  // ---- PACKAGE function ----
  Top103 gtop;
  function automatic void PF103();
    gtop.md.one.lvoid(200);
  endfunction
  function automatic int PG103();
    return gtop.md.one.lfun(201);
  endfunction
  function automatic void PF2();
    gtop.lz.lvoid(202);
  endfunction

  // ---- CLASS-SCOPE root (Surelog's paClass_scope arm) ----
  class Stat103;
    static Mid103 sm = new();
  endclass
  function automatic void PS103();
    Stat103::sm.one.lvoid(211);
  endfunction

endpackage

module m103;
  import Pk103::*;
  Top103 tt;
  Mid103 mm;
  int zz;
  initial begin
    tt = new();
    mm = new();
    mm.one.lvoid(222);
    tt.md.one.lvoid(233);
    mm.dp.dleaf.lvoid(234);
    mm.one.ltask(235);
    zz = mm.one.lfun(244);
  end
  function void MF3(); mm.one.lvoid(255); endfunction
  function void MF2(); mm.mvoid(256);     endfunction
endmodule
