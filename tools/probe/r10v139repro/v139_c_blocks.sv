// r10v139 arm C — BLOCK-LOCAL faces and FORMAL ARGUMENTS.  These are the
// faces § r10fsv3 / § blockDeclAutomaticIsWrittenKw80 own; this pass must not
// move any of them.  Locals inside begin / fork / for, plus formals.
package Winch139;
  class Grommet139;
    // begin-block locals inside a TF-ITEM subroutine
    function void begInTf139;
      int   ua;            // tf-item
      static int ub;       // tf-item, static
      begin : nest139
        int   uc;          // nested begin -> block rule
        static int ud;
        automatic int ue;
        uc = 1; ud = 2; ue = 3;
      end
      ua = 1; ub = 2;
    endfunction
    // begin-block locals inside a BLOCK subroutine
    function void begInBlk139();
      int   va;
      begin : nest2139
        int   vb;
        automatic int vc;
        static int vd;
        vb = 1; vc = 2; vd = 3;
      end
      va = 1;
    endfunction
    // for-loop body locals
    function void forBody139;
      int   wa;
      for (int wi = 0; wi < 3; wi++) begin
        int   wb;
        automatic int wc;
        static int wd;
        wb = wi; wc = wi; wd = wi;
      end
      wa = 1;
    endfunction
    // formal arguments, three spellings
    function void formals139(int xa, ref int xb, output int xc);
      xc = xa + xb;
    endfunction
    function automatic void formalsAuto139(input int ya, output int yb);
      yb = ya;
    endfunction
    task formalsTask139(input int za, output int zb);
      int zc;
      zc = za; zb = zc;
    endtask
  endclass
endpackage

module Bollard139;
  // fork block locals
  task forkTask139;
    input int fi139;
    int   ab1;
    static int ab2;
    fork
      begin
        int   ac1;
        automatic int ac2;
        static int ac3;
        ac1 = fi139; ac2 = 1; ac3 = 2;
      end
    join_none
    ab1 = 1; ab2 = 2;
  endtask
  // initial / always block locals
  initial begin
    int   ad1;
    automatic int ad2;
    static int ad3;
    ad1 = 1; ad2 = 2; ad3 = 3;
  end
  always @(*) begin
    int   ae1;
    automatic int ae2;
    ae1 = 1; ae2 = 2;
  end
  // module function with formals and a nested for
  function int mixFn139(input int af1, input int af2);
    int ag1;
    ag1 = af1;
    for (int aj = 0; aj < 2; aj++) begin
      automatic int ah1 = aj;
      ag1 = ag1 + ah1;
    end
    return ag1 + af2;
  endfunction
  initial forkTask139(3);
endmodule
