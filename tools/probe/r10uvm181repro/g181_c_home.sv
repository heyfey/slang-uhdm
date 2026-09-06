// r10uvm181 arm C -- THE HOME GRID (which SCOPE the EMPTYTF body lives in).
//
// Pass 37's clone only exists for a subroutine the HOME PACKAGE lists, so this
// arm puts the identical EMPTYTF foreach body in every home the corpus has and
// reads the views apart:
//
//   * a package FREE function     -- cloned, both views
//   * a package FREE task         -- the task half of the same question
//   * an OUT-OF-BODY class method -- a package item, so cloned (pass 37, t51b)
//   * an INLINE class method      -- NOT in the package's subroutine listing,
//                                    so never cloned; the NEGATIVE that keeps
//                                    the law from being written for every
//                                    method
//   * a MODULE task               -- no clone at all; its references take
//                                    ExprEmit's implicit-net arm
//
// and the importer is a package (trove181_imp) so both the DEF and the
// ELABORATED listing of the clone are produced.  A class method iterates a
// CLASS PROPERTY (Surelog rejects a package variable reached from a class
// body: EL0514 "Undefined variable"), which is also the corpus shape --
// uvm_table_printer::calculate_max_widths iterates the property m_rows.
package trove181_home;

  int cairn181_arr [5];
  int cairn181_q   [$];

  class trove181_cls;
    int menhir181 [4];
    extern function void outofbody181();
    // INLINE: never a package item, so never cloned.
    function void inline181();
      foreach (menhir181[dolmen]) begin
        int barrow;
        barrow = menhir181[dolmen] + dolmen;
      end
    endfunction
  endclass

  // OUT-OF-BODY: a package item, and EMPTYTF (no formals, no own locals).
  function void trove181_cls::outofbody181();
    foreach (menhir181[tumulus]) begin
      int barrow;
      barrow = menhir181[tumulus] + tumulus;
    end
  endfunction

  // FREE function, EMPTYTF.
  function automatic void free181_fn();
    foreach (cairn181_q[henge]) begin
      int barrow;
      barrow = cairn181_q[henge] + henge;
    end
  endfunction

  // FREE task, EMPTYTF.
  task automatic freetask181_tk();
    foreach (cairn181_arr[stele]) begin
      int barrow;
      barrow = cairn181_arr[stele] + stele;
    end
  endtask

  // CONTROL -- the out-of-body method with one function-scope local, so lm9
  // was never empty and this cell cannot move.
  class trove181_prop;
    int quoit181 [3];
    extern function void propfn181();
  endclass

  function void trove181_prop::propfn181();
    int lychgate;
    foreach (quoit181[cromlech]) begin
      int barrow;
      barrow = quoit181[cromlech] + cromlech;
      lychgate = barrow;
    end
  endfunction

endpackage

package trove181_imp;
  import trove181_home::*;
  int trove181_anchor;
endpackage

// A MODULE home: never cloned, and its loop-variable references take the
// implicit-net arm.  Nothing here may move.
module trove181_mod;
  int lintel181_arr [5];
  task automatic modtask181();
    foreach (lintel181_arr[sarsen]) begin
      int barrow;
      barrow = lintel181_arr[sarsen] + sarsen;
    end
  endtask
  initial begin
    trove181_imp::trove181_anchor = 0;
    modtask181();
  end
endmodule
