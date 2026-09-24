// r10uvm131 arm E — the END-LABEL half of the same par_block scan, and the
// named_begin CONTROL that proves the quirk is fork-only.
//
// CompileStmt's par_block arm starts its end-label search at
// Sibling(item) — ONE NODE PAST the first item — so an EMPTY fork never sees
// its own join keyword: no vpiJoinType AND no vpiEndLabel.  CompileStmt's
// seq_block arm starts AT item, so an EMPTY named begin KEEPS its end label.
module ArmEEndLbl;
  int w, x, y, z;
  initial begin
    // named begin, empty, with an end label  (CONTROL: label must SURVIVE)
    begin : emptyBeg
    end : emptyBeg
    // named begin, empty, no end label
    begin : emptyBeg2
    end
    // named begin, non-empty, with an end label
    begin : fullBeg
      w = 1;
    end : fullBeg
    // (a `join : lbl` on an UNNAMED fork is SLANG-REJECTED — "trailing name
    // not allowed on previously unnamed block" — so that Surelog shape
    // (named_fork with an end label and no name) is out of scope here.)
    fork
      x = 2;
    join
    fork
      y = 3;
    join_none
    // EMPTY named forks, all three joins, with and without end labels
    fork : eF1
    join
    fork : eF2
    join_any
    fork : eF3
    join_none : eF3
    fork : eF4
    join : eF4
    // non-empty named fork with end label (the RIGHT-side control)
    fork : fullFork
      z = 4;
    join_none : fullFork
  end
endmodule
