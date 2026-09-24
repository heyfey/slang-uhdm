// r10uvm62 arm c2 — THE NEIGHBOUR arm.  class_defn is ONE of EIGHT UHDM object
// types that own a `vpiEndLabel` slot (class_defn, module_inst, interface_inst,
// program, package, named_begin, named_event, named_fork — the exhaustive list,
// read out of ~/git-repos/UHDM/model/*.yaml, not guessed).  This arm puts a
// LABELLED and a BARE instance of every one of them in the same file, so the
// pass can state which neighbours were already correct, which are residues, and
// prove that the class writer is the only one it needs to touch.
//
// It is also the NEGATIVE CONTROL for the patch: none of these rows may move.

package pk_lbl;
  int pv;
endpackage : pk_lbl

package pk_bare;
  int pv;
endpackage

interface if_lbl;
  logic a;
endinterface : if_lbl

interface if_bare;
  logic b;
endinterface

program pg_lbl;
  initial begin end
endprogram : pg_lbl

program pg_bare;
  initial begin end
endprogram

module m_lbl;
  logic x;

  // named_begin, labelled `end : nb_lbl`
  initial begin : nb_lbl
    x = 1'b0;
  end : nb_lbl

  // named_begin, bare `end`
  initial begin : nb_bare
    x = 1'b1;
  end

  // named_fork — `join_none : nf_lbl` (the uvm_objection::guard shape)
  initial begin
    fork : nf_lbl
      x = 1'b0;
    join_none : nf_lbl
  end

  // named_fork, bare join
  initial begin
    fork : nf_bare
      x = 1'b1;
    join_none
  end

  // the uvm_objection shape EXACTLY: a labelled BEGIN inside an unnamed fork
  initial begin
    fork
      begin : guard_lbl
        x = 1'b0;
      end : guard_lbl
    join_none
  end

endmodule : m_lbl

module m_bare;
  logic y;
  initial y = 1'b0;
endmodule
