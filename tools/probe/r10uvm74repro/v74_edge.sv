// VERIFIER arm v74_edge — the REFUSAL paths and the EMPTY PRODUCT CELLS of
// § builtinRecvIndexedStepIsBitSelect74.  Every cell here is one the
// implementer's four arms do NOT contain.
package pe;
  localparam int PE = 1;
endpackage

module v74_edge;
  import pe::*;

  class leaf;
    string s;
    string sq[$];
    function int getl(); return s.len(); endfunction
  endclass

  class mid;
    leaf   lq[$];
    leaf   l;
    string sq[$];
    int    iq[$];
  endclass

  class idxholder;
    int k;
  endclass

  class user;
    mid    mq[$];
    mid    m;
    string sq[$];
    int    iq[$];
    string qq[$][$];      // multi-dimensional
    idxholder ih;
    int    r;
    string t;

    function int fidx(int a); return a; endfunction

    function void f(int i, int j);
      // ---- REFUSAL cells (the helper must decline; pre-existing ref_obj) ----
      // e_multidim: TWO index groups on one component
      r = qq[i][j].len();
      // e_dotidx: a DOT INSIDE the index -- the naive '.' text split breaks
      r = sq[ih.k].len();
      // e_callidx: a CALL inside the index
      r = sq[fidx(i)].len();
      // ---- EMPTY PRODUCT cells (kind x position, unmeasured by b1..b4) ----
      // p_litmid: an INTEGER LITERAL index on a MIDDLE step
      r = m.sq[2].len();
      // p_cpdmid: a COMPOUND index on a MIDDLE step
      r = m.sq[j + 1].len();
      // p_litboth: literal on base AND literal on middle
      r = mq[0].sq[1].len();
      // p_spacelit: a literal written WITH SPACES inside the brackets
      r = sq[ 2 ].len();
      // p_parenless_mid: parens-less builtin over a MIDDLE-indexed path
      r = m.sq[i].len;
      // p_deepmethod: indexed base + member + member + builtin
      r = mq[i].l.s.len();
      // p_usermeth_idx: a USER method on an indexed receiver (must not move)
      r = mq[i].lq[j].getl();
    endfunction

    // ---- c_stmt with an INDEX: the STATEMENT form's Prefix ref_obj ----
    function void g(int i);
      sq[i].itoa(3);
      mq[i].sq.push_back("x");
    endfunction

    // ---- R2: a `with` clause over an INDEXED receiver (fenced OUT) ----
    function void w(int i);
      r = mq[i].iq.sum() with (item);
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f(0, 1);
    u.g(0);
    u.w(0);
  end
endmodule
