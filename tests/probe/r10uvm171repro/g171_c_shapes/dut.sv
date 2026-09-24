// r10uvm171 arm a3 — THE BODY-SHAPE AND USE GRID, all inside the cloned home
// so every cell is in the law's window.  The axes: where the locals are
// declared (leading block / named begin / mid-body / none / two blocks), how
// the return name is used (assigned only / read only / selected only / never),
// and whether the select sits at body top level, inside a named begin, inside
// a loop or inside a conditional.  If the law were really about a DECLARATION
// LISTING rather than a BINDING, these cells would split; they must not.
package shape_src_171;
  // leading declaration block, select at body top level
  function string lead_blk();
    int aa;
    int bb;
    lead_blk = "gantry";
    aa = lead_blk.len();
    bb = aa - 1;
    lead_blk[0] = lead_blk[bb];
  endfunction

  // declarations inside a NAMED begin, select inside it too
  function string named_blk();
    begin : nb171
      int cc;
      named_blk = "trellis";
      cc = named_blk.len() - 1;
      named_blk[0] = named_blk[cc];
    end
  endfunction

  // a MID-BODY declaration (after the first statement)
  function string mid_decl();
    mid_decl = "lantern";
    begin
      int dd;
      dd = mid_decl.len() - 1;
      mid_decl[0] = mid_decl[dd];
    end
  endfunction

  // NO locals at all
  function string no_local();
    no_local = "quill";
    no_local[0] = no_local[1];
  endfunction

  // TWO separate blocks, one select in each
  function string two_blks();
    two_blks = "obelisk";
    begin : b1_171
      int ee;
      ee = 1;
      two_blks[0] = two_blks[ee];
    end
    begin : b2_171
      int ff;
      ff = 2;
      two_blks[1] = two_blks[ff];
    end
  endfunction

  // the return name is ASSIGNED but never read or selected
  function string asg_only();
    asg_only = "cairn";
  endfunction

  // the return name is READ but never selected
  function string read_only();
    read_only = "flume";
    if (read_only != "") read_only = "flume2";
  endfunction

  // the return name is SELECTED inside a LOOP and inside a CONDITIONAL
  function string loop_cond();
    int gg;
    loop_cond = "spandrel";
    for (gg = 0; gg < 3; gg++)
      loop_cond[gg] = loop_cond[gg+1];
    while (gg < 5) begin
      loop_cond[gg] = loop_cond[0];
      gg++;
    end
    if (loop_cond.len() > 2)
      loop_cond[0] = loop_cond[2];
  endfunction
endpackage

package shape_clone_171;
  import shape_src_171::*;
  // The calls are assigned to locals and the lengths taken from THOSE: a
  // `.len()` chained straight onto a call RESULT is a different emitter shape
  // entirely (golden makes it a `func_call`, we make it a `hier_path`) and it
  // is a pre-existing head of its own — carrying it here would put an
  // unrelated defect in front of the cells this arm exists to score.
  function int drive_shapes();
    string s1; string s2; string s3; string s4;
    string s5; string s6; string s7; string s8;
    s1 = lead_blk();
    s2 = named_blk();
    s3 = mid_decl();
    s4 = no_local();
    s5 = two_blks();
    s6 = asg_only();
    s7 = read_only();
    s8 = loop_cond();
    return s1.len() + s2.len() + s3.len() + s4.len() +
           s5.len() + s6.len() + s7.len() + s8.len();
  endfunction
endpackage

module shape_top_171;
  import shape_clone_171::*;
  int rr;
  initial rr = drive_shapes();
endmodule
