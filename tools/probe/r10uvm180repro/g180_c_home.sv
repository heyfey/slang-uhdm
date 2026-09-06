// r10uvm180 arm C — THE HOME CONTROL, and the EXPLICIT-import shape.
// The law must move a CLONE body and nothing else.  This arm puts the same
// subroutine in three roles at once:
//   * the HOME package's own copy (must keep `hz180_root::` on its alias);
//   * a WILDCARD importer's clone (must go bare);
//   * an EXPLICIT importer's clone of ONE named subroutine — Surelog's
//     `importPackage` clones a task_func whenever `inPackage` is true, named
//     or not, so this cell is a clone too.
// It also carries a package with NO import at all, whose bodies must be
// untouched in both binaries.
package hz180_root;
  typedef logic [11:0] slate_lt;
  typedef bit  [7:0]   chalk_bt;

  function automatic int unsigned slate_fn(slate_lt lode);
    slate_lt drift;
    drift = lode;
    if (drift != 0) begin
      slate_lt stope;
      stope = drift - 1;
      drift = stope;
    end
    return int'(drift);
  endfunction

  function automatic int unsigned chalk_fn(chalk_bt lode);
    chalk_bt drift;
    drift = lode;
    begin
      chalk_bt stope;
      stope = drift + 1;
      drift = stope;
    end
    return int'(drift);
  endfunction
endpackage

package hz180_wild;
  import hz180_root::*;
endpackage

package hz180_named;
  import hz180_root::slate_fn;
endpackage

// no import at all — a pure negative control with the SAME typedef spelling
package hz180_alone;
  typedef logic [11:0] slate_lt;
  function automatic int unsigned slate_fn(slate_lt lode);
    slate_lt drift;
    drift = lode;
    begin
      slate_lt stope;
      stope = drift + 2;
      drift = stope;
    end
    return int'(drift);
  endfunction
endpackage

module hz180_top;
  import hz180_root::*;
  slate_lt adit;
  chalk_bt seam;
  int unsigned tally;
  initial begin
    adit = 12'h0a5;
    seam = 8'h3c;
    tally = slate_fn(adit) + chalk_fn(seam) + hz180_alone::slate_fn(adit);
  end
endmodule
