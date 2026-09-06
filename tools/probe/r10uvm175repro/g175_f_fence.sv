// r10uvm175 arm F — MULTIPLICITY, ROOTS and the neighbouring laws' cells that
// must stay put: a receiver with no select at all, a package-scoped root, a
// virtual-interface root, a STATEMENT-position twin (§ selRecvStmtCallBareNames124's
// own cell), and the same expression written three times.
interface fq_bus;
  int slots[$];
endinterface
package foxtrot_quay;
  class tally_box;
    string words[$];
    int nums[$];
    function new(); endfunction
  endclass
  tally_box pkg_shelf[4];
  class ledger;
    tally_box shelves[$];
    tally_box plain;
    int reg_out[$];
    int single;
    string wanted;
    virtual fq_bus vif;
    function void audit(int slot);
      // f_nosel: no select anywhere (must stay two plain ref_objs)
      reg_out = plain.words.find_index() with (item == wanted);
      // f_pkgroot: a PACKAGE-scoped indexed root
      reg_out = foxtrot_quay::pkg_shelf[slot].words.find_index() with (item == wanted);
      // f_vif: a VIRTUAL INTERFACE root with a with-clause locator
      reg_out = vif.slots.find_index() with (item == slot);
      // f_stmt: STATEMENT position over an indexed receiver (uvm124's law)
      shelves[slot].words.push_back("f_stmt");
      // f_stmt2: STATEMENT position, no with, single component
      shelves[slot].nums.delete();
      // f_thrice_1 / _2 / _3: the SAME with-form written three times
      reg_out = shelves[slot].words.find_index() with (item == wanted);
      reg_out = shelves[slot].words.find_index() with (item == wanted);
      reg_out = shelves[slot].words.find_index() with (item == wanted);
      // f_read: an ordinary indexed READ through a dotted path (already
      // bit_select in pristine — the neighbouring family's control)
      reg_out = shelves[slot].nums;
      // f_readsel: an ordinary indexed READ of one element
      single = shelves[slot].nums[0];
    endfunction
  endclass
endpackage
