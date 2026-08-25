// r10v134 grid 3 — LOOP-LIST SHAPES, including the CONTROLS that must not move.
package spk3;

  typedef struct { int sfa[$]; int sfb[3]; } srec3_t;

  class Deep3;
    int dq[$];
    int dr[];
  endclass

  class Mid3;
    Deep3 mq[$];
    Deep3 mone;
    int mv[$];
  endclass

  class Top3;
    Mid3 tmids[$];
    Mid3 tone;
    int tflat[$];
    int tgrid[3][4];
    srec3_t tstructs[$];      // ARRAY OF STRUCT
    Deep3 tdeeps[$];

    // --- CONTROLS: must be untouched by the rewrite ---
    function void c_bare();      foreach (tflat[q1]) $display(q1); endfunction
    function void c_2dim();      foreach (tgrid[q2,q3]) $display(q2,q3); endfunction
    function void c_2sep();      foreach (tgrid[q4]) foreach (tgrid[q4][q5]) $display(q5); endfunction
    function void c_dot1();      foreach (tone.mv[q6]) $display(q6); endfunction
    function void c_dot2();      foreach (tone.mone.dq[q7]) $display(q7); endfunction
    function void c_thisbare();  foreach (this.tflat[q8]) $display(q8); endfunction
    function void c_thisdot();   foreach (this.tone.mv[q9]) $display(q9); endfunction
    function void c_skip();      foreach (tgrid[,qa]) $display(qa); endfunction
    function void c_skip2();     foreach (tgrid[qb,]) $display(qb); endfunction

    // --- THE LAW'S OWN SHAPES ---
    // root indexed, one member
    function void l_idxdot();    foreach (tmids[qc]) foreach (tmids[qc].mv[qd]) $display(qd); endfunction
    // root indexed, member, indexed, member (3 deep)
    function void l_idxdot3();
      foreach (tmids[qe]) foreach (tmids[qe].mq[qf]) foreach (tmids[qe].mq[qf].dq[qg]) $display(qg);
    endfunction
    // root indexed, TWO members after the select
    function void l_idx2mem();   foreach (tmids[qh]) foreach (tmids[qh].mone.dq[qi]) $display(qi); endfunction
    // DOTTED root, indexed member, member
    function void l_dotidxdot(); foreach (tone.mq[qj]) foreach (tone.mq[qj].dq[qk]) $display(qk); endfunction
    // this. root, indexed, member
    function void l_thisidxdot(); foreach (this.tmids[ql]) foreach (this.tmids[ql].mv[qm]) $display(qm); endfunction
    // this. DOTTED, indexed member, member  (R1 shape)
    function void l_thisdotidx(); foreach (this.tone.mq[qn]) foreach (this.tone.mq[qn].dq[qo]) $display(qo); endfunction
    // ARRAY OF STRUCT: select then struct field
    function void l_structfld(); foreach (tstructs[qp]) foreach (tstructs[qp].sfa[qq]) $display(qq); endfunction
    function void l_structfix(); foreach (tstructs[qr]) foreach (tstructs[qr].sfb[qs]) $display(qs); endfunction
    // 2-D root select then member
    function void l_2didxdot();  Mid3 gm[2][2]; foreach (gm[qt,qu]) foreach (gm[qt][qu].mv[qv]) $display(qv); endfunction
    // LOCAL array root
    function void l_localidx();  Mid3 lm[$]; foreach (lm[qw]) foreach (lm[qw].mv[qx]) $display(qx); endfunction
    // FORMAL array root
    function void l_formalidx(ref Mid3 fm[$]); foreach (fm[qy]) foreach (fm[qy].mv[qz]) $display(qz); endfunction
  endclass

  Top3 pkgtops[2];
  Mid3 pkgmids[$];

  function void pkg_idxdot3();
    foreach (pkgmids[r1]) foreach (pkgmids[r1].mv[r2]) $display(r2);
  endfunction

endpackage
