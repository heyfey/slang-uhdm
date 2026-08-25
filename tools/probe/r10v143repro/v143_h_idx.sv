// r10v143 arm H — THE INDEX-EXPRESSION AXIS on the binding shape, inside an
// IN-BODY class method, with an OUT-OF-BODY twin for every shape.  If any of
// these is a shape golden BINDS inside a class body, the patch breaks it.
package pkH143v;
  class Pip; int tally; int gauge; endclass
  typedef enum int { HP_NIL = 0, HP_ONE = 1 } hgrade_e;
  typedef struct { int lo; int hi; } hpair_t;
  parameter  int HP_SLOT = 2;
  localparam int HL_SLOT = 3;
  function automatic int hseed(int a); return a + 1; endfunction

  class Hkey; int kid; static int s_key = 1; endclass

  class Hin;
    Pip byInt[int];
    Pip byStr[string];
    Pip byHnd[Hkey];
    Pip byEnm[hgrade_e];
    Pip byQ[$];
    Pip byArr[4][4];
    int  mote;
    static int s_mote = 1;
    hpair_t pr;
    int  vec[8];
    bit [31:0] bv;
    Hkey kh;

    task h01(); if (byInt[3].tally == 0) $display("h01"); endtask
    task h02(); if (byInt[HP_SLOT].tally == 0) $display("h02"); endtask
    task h03(); if (byInt[HL_SLOT].tally == 0) $display("h03"); endtask
    task h04(); if (byInt[mote].tally == 0) $display("h04"); endtask
    task h05(); if (byInt[s_mote].tally == 0) $display("h05"); endtask
    task h06(); if (byInt[this.mote].tally == 0) $display("h06"); endtask
    task h07(int f); if (byInt[f].tally == 0) $display("h07"); endtask
    task h08(); int lv; lv = 1; if (byInt[lv].tally == 0) $display("h08"); endtask
    task h09(int f); if (byInt[f + 1].tally == 0) $display("h09"); endtask
    task h10(int f); if (byInt[(f + mote) * 2].tally == 0) $display("h10"); endtask
    task h11(int f); if (byInt[hseed(f)].tally == 0) $display("h11"); endtask
    task h13(int f); if (byInt[f ? mote : 1].tally == 0) $display("h13"); endtask
    task h14(int f); if (byInt[{f[7:0], 8'd1}].tally == 0) $display("h14"); endtask
    task h15(int f); if (byInt[int'(f)].tally == 0) $display("h15"); endtask
    task h16();      if (byInt[$bits(bv)].tally == 0) $display("h16"); endtask
    task h17();      if (byStr["kk"].tally == 0) $display("h17"); endtask
    task h18(string s); if (byStr[s].tally == 0) $display("h18"); endtask
    task h19(Hkey h); if (byHnd[h].tally == 0) $display("h19"); endtask
    task h20();      if (byHnd[kh].tally == 0) $display("h20"); endtask
    task h21();      if (byEnm[HP_ONE].tally == 0) $display("h21"); endtask
    task h22(hgrade_e e); if (byEnm[e].tally == 0) $display("h22"); endtask
    task h23();      if (byInt[pr.lo].tally == 0) $display("h23"); endtask
    task h24(int f); if (byInt[vec[f]].tally == 0) $display("h24"); endtask
    task h25(int f); if (byInt[vec[f + 1]].tally == 0) $display("h25"); endtask
    task h26(int f); if (byInt[bv[7:0]].tally == 0) $display("h26a");
                     if (byInt[bv[f +: 4]].tally == 0) $display("h26b"); endtask
    task h27();      if (byQ[$].tally == 0) $display("h27"); endtask
    task h28(int f); if (byQ[f].tally == 0) $display("h28"); endtask
    task h29(int f, int g); if (byArr[f][g].tally == 0) $display("h29"); endtask
    task h30(Hkey h); if (byInt[h.kid].tally == 0) $display("h30"); endtask
    task h31();      if (byInt[Hkey::s_key].tally == 0) $display("h31"); endtask
    task h32(int f); if (byInt[f].tally == byInt[f].gauge + byInt[f + 0].tally)
                       $display("h32"); endtask
    task h33(int f, int g); if (byArr[f][g].tally == byInt[f].gauge)
                       $display("h33"); endtask
  endclass

  class Hoo;
    Pip byInt[int];
    Pip byStr[string];
    Pip byHnd[Hkey];
    Pip byArr[4][4];
    int mote;
    int vec[8];
    bit [31:0] bv;
    hpair_t pr;
    extern task o07(int f);
    extern task o09(int f);
    extern task o11(int f);
    extern task o13(int f);
    extern task o16();
    extern task o18(string s);
    extern task o19(Hkey h);
    extern task o23();
    extern task o24(int f);
    extern task o29(int f, int g);
    extern task o30(Hkey h);
    extern task o31();
    extern task o04();
  endclass
  task Hoo::o07(int f); if (byInt[f].tally == 0) $display("o07"); endtask
  task Hoo::o09(int f); if (byInt[f + 1].tally == 0) $display("o09"); endtask
  task Hoo::o11(int f); if (byInt[hseed(f)].tally == 0) $display("o11"); endtask
  task Hoo::o13(int f); if (byInt[f ? mote : 1].tally == 0) $display("o13"); endtask
  task Hoo::o16();      if (byInt[$bits(bv)].tally == 0) $display("o16"); endtask
  task Hoo::o18(string s); if (byStr[s].tally == 0) $display("o18"); endtask
  task Hoo::o19(Hkey h); if (byHnd[h].tally == 0) $display("o19"); endtask
  task Hoo::o23();      if (byInt[pr.lo].tally == 0) $display("o23"); endtask
  task Hoo::o24(int f); if (byInt[vec[f]].tally == 0) $display("o24"); endtask
  task Hoo::o29(int f, int g); if (byArr[f][g].tally == 0) $display("o29"); endtask
  task Hoo::o30(Hkey h); if (byInt[h.kid].tally == 0) $display("o30"); endtask
  task Hoo::o31();      if (byInt[Hkey::s_key].tally == 0) $display("o31"); endtask
  task Hoo::o04();      if (byInt[mote].tally == 0) $display("o04"); endtask
endpackage

module topH143v;
  pkH143v::Hin hi; pkH143v::Hoo ho;
  initial begin hi = new(); ho = new(); hi.h07(1); ho.o07(1); end
endmodule
