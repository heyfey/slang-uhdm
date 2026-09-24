// r10uvm143 arm A — WHEN DOES A hier_path INDEX REF BIND ITS ACTUAL?
// The head site is uvm_objection.svh:915 `if (m_events[obj].waiters == 0)`:
// golden leaves the bit_select INDEX ref_obj unbound, we bind it to the formal's
// io_decl.  Names deliberately unlike the UVM ones and unlike each other.
package Quarry_pkg;

  class Slate;
    int tally;
    int gauge;
  endclass

  class Ledger;
    Slate ridge[Slate];
    Slate rows[int];
    int   plain[int];
    Slate scalarSlate;

    // A: hier_path index is a FORMAL WITH A DEFAULT (the head's own shape)
    task probeDefaulted(Slate seam = null);
      if (ridge[seam].tally == 0) $display("a");
    endtask

    // B: hier_path index is a FORMAL WITHOUT a default
    task probePlainFormal(Slate seam);
      if (ridge[seam].tally == 0) $display("b");
    endtask

    // C: hier_path index is a BODY LOCAL
    task probeLocal();
      Slate seam;
      if (ridge[seam].tally == 0) $display("c");
    endtask

    // D: hier_path index is a CLASS PROPERTY
    task probeProp();
      if (ridge[scalarSlate].tally == 0) $display("d");
    endtask

    // E: INTEGER index formal with a default, integer-keyed array
    task probeIntKey(int slot = 3);
      if (rows[slot].tally == 0) $display("e");
    endtask

    // F: plain bit_select (NOT inside a hier_path), formal with default
    task probeBareSel(int slot = 4);
      if (plain[slot] == 0) $display("f");
    endtask

    // G: hier_path index formal-with-default under an EVENT CONTROL
    //     (uvm_objection.svh:908 shape — golden does not bind there either)
    task probeEventCtl(Slate seam = null);
      $display("g", ridge[seam].gauge);
    endtask

    // H: hier_path index used as an ASSIGNMENT LHS base
    task probeAsgnLhs(Slate seam = null);
      ridge[seam].tally = 7;
    endtask

    // I: two DIFFERENT defaulted formals, both used as hier_path indices
    task probeTwo(Slate seam = null, int slot = 5);
      if (ridge[seam].tally == rows[slot].gauge) $display("i");
    endtask
  endclass
endpackage

module quarryTop;
  Quarry_pkg::Ledger book;
  initial begin
    book = new();
    book.probeDefaulted();
  end
endmodule
