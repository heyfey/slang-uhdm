// r10v143 arm M — the RECURSION BRANCHES the helper walks that no other arm
// reaches: a METHOD CALL as the index (its RECEIVER is cleared by the walk), a
// system-function call, a `with`-clause array method, a randomize call, a
// nested hier_path index, a var_select (multi-dim) element index and a
// part-select range.  Each has an OUT-OF-BODY twin: if golden binds any of
// them inside a class body the patch turns a right cell wrong.
package pkM143v;
  class Mite; int tally; int gauge; function int mid(); return 1; endfunction endclass

  class MinM;
    Mite tbl[int];
    Mite grid[4][4];
    Mite kh;
    int  vec[8];
    int  q[$];
    bit [31:0] bv;
    rand int rv;

    task m01(Mite h);        if (tbl[h.mid()].tally == 0) $display("m01"); endtask
    task m02(Mite h);        if (tbl[h.tally].tally == 0) $display("m02"); endtask
    task m03();              if (tbl[kh.mid()].tally == 0) $display("m03"); endtask
    task m04();              if (tbl[this.kh.tally].tally == 0) $display("m04"); endtask
    task m05();              if (tbl[$size(vec)].tally == 0) $display("m05"); endtask
    task m06();              if (tbl[q.size()].tally == 0) $display("m06"); endtask
    task m07(int f);         if (tbl[vec.sum() + f].tally == 0) $display("m07"); endtask
    task m08(int f, int g);  if (grid[f][g].tally == 0) $display("m08"); endtask
    task m09(int f);         if (tbl[bv[f +: 4]].tally == 0) $display("m09"); endtask
    task m10(int f);         if (tbl[bv[f -: 4]].gauge == 0) $display("m10"); endtask
    task m11(int f);         if (tbl[{f, f}].tally == 0) $display("m11"); endtask
    task m12(Mite h, int f); if (tbl[h.mid() + vec[f]].tally == 0) $display("m12"); endtask
  endclass

  class MooM;
    Mite tbl[int];
    Mite grid[4][4];
    Mite kh;
    int  vec[8];
    int  q[$];
    bit [31:0] bv;
    extern task n01(Mite h);
    extern task n02(Mite h);
    extern task n03();
    extern task n05();
    extern task n06();
    extern task n08(int f, int g);
    extern task n09(int f);
    extern task n12(Mite h, int f);
  endclass
  task MooM::n01(Mite h);       if (tbl[h.mid()].tally == 0) $display("n01"); endtask
  task MooM::n02(Mite h);       if (tbl[h.tally].tally == 0) $display("n02"); endtask
  task MooM::n03();             if (tbl[kh.mid()].tally == 0) $display("n03"); endtask
  task MooM::n05();             if (tbl[$size(vec)].tally == 0) $display("n05"); endtask
  task MooM::n06();             if (tbl[q.size()].tally == 0) $display("n06"); endtask
  task MooM::n08(int f, int g); if (grid[f][g].tally == 0) $display("n08"); endtask
  task MooM::n09(int f);        if (tbl[bv[f +: 4]].tally == 0) $display("n09"); endtask
  task MooM::n12(Mite h, int f);if (tbl[h.mid() + vec[f]].tally == 0) $display("n12"); endtask
endpackage

module topM143v;
  pkM143v::MinM mi; pkM143v::MooM mo; pkM143v::Mite h;
  initial begin mi = new(); mo = new(); h = new(); mi.m01(h); mo.n01(h); end
endmodule
