// r10uvm202 arm C — THE SITE.
// Every place a local of a package-scope class typedef can be written inside a
// cloned out-of-body method body, with a plain-package-typedef control beside
// each one: the tf item, the tf item WITH AN INITIALISER (the corpus head's own
// shape, `uvm_reg_field_cb_iter cbs = new(this);`), a plain `begin`, a NAMED
// begin, a loop body, an `if` arm, a `case` item (where the corpus head lives)
// and a `fork` arm.  The FORMAL is here too, as § 36's must-stay.
package quarry202c;
  class Plain202c;
    int lode202c;
    function new(); endfunction
  endclass
  typedef Plain202c pkgCls202c;        // the LAW's type
  typedef int       pkgInt202c;        // CONTROL beside every cell

  class Adit202c;
    extern function void winze202c(pkgCls202c formal202c);
  endclass

  function void Adit202c::winze202c(pkgCls202c formal202c);   // § 36's FORMAL
    pkgCls202c cTf202c;                        // tf item
    pkgCls202c cTfInit202c = new();            // tf item WITH INITIALISER
    pkgInt202c cTfInt202c;                     // CONTROL
    int        i202c;
    begin
      pkgCls202c cBlk202c;                     // plain begin
      pkgInt202c cBlkInt202c;                  // CONTROL
      cBlk202c = null;
      cBlkInt202c = 0;
    end
    begin : named202c
      pkgCls202c cNamed202c;                   // NAMED begin
      cNamed202c = null;
    end
    for (i202c = 0; i202c < 2; i202c++) begin
      pkgCls202c cLoop202c;                    // loop body
      cLoop202c = null;
    end
    if (i202c == 0) begin
      pkgCls202c cIf202c;                      // if arm
      cIf202c = null;
    end
    case (i202c)
      0: begin
        pkgCls202c cCase202c;                  // CASE ITEM — the corpus head
        cCase202c = null;
      end
      default: ;
    endcase
    fork
      begin
        pkgCls202c cFork202c;                  // fork arm
        cFork202c = null;
      end
    join_none
    cTf202c = null;
    cTfInit202c = null;
    cTfInt202c = 0;
  endfunction
endpackage

package sluice202c;
  import quarry202c::*;
  class Flume202c;
    function void race202c();
      Adit202c gate202c;
      gate202c = null;
    endfunction
  endclass
endpackage
