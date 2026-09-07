// r10v191 ADVERSARIAL ARM E — THE STATEMENT-SHAPE AXIS and MULTIPLICITY.
//
// The shipped hop is recorded in ExprEmit's NewArray arm as
// `newArrayCloneOwner191[mfc] = parent`, where `parent` is whatever
// `emitExpr` was handed.  Arms A/B/C only ever write the `new[...]` on the
// right-hand side of a BLOCKING ASSIGNMENT inside a function, so `parent` is
// always an `assignment` whose chain reaches the enclosing `function`.  This
// arm asks what happens when `parent` is something ELSE, and what happens
// when the SAME face appears MORE THAN ONCE.
//
// Rows:
//   E1     a `new[...]` inside a TASK (not a function) — `ownerTf9` accepts
//          `uhdmtask` too, so the hop must reach it.
//   E2     a `new[...]` in a DECLARATION INITIALISER, where the enclosing
//          object is not an assignment at all.
//   E3     a `new[...]` inside a `foreach` BODY whose base is the FOREACH
//          LOOP VARIABLE (`loopVar37`, reached only by `bind9`'s climb).
//   E4     a `new[...]` inside an `if` branch, nested two blocks deep.
//   E5     the COPY form's SECOND argument carrying a hier_path base.
//   E6     a `new[...]` whose size expression contains ANOTHER `new[...]`'s
//          result read back — two windows in one statement.
//   E7     a select INDEX that is itself a hier_path base, under `new[...]`.
//   E8..E10  THE SAME face written ONE, TWO and THREE times over three
//          distinct locals, to prove the hop is per-object and not a
//          last-writer.
//   E11    a `new[...]` in a function called from TWO DIFFERENT wildcard
//          importers, i.e. the same home body cloned into two listings.
//   E12    a `new[...]` inside a `while` body.
//
// Names, numbers and orders are deliberately unlike the corpus' and unlike
// arms A/B/C/D.
package Futtock191;

  typedef int Rove191[];

  typedef struct { int garboard191; int strake191[$]; } Chine191;

  int pkgsheer191[string];

  class Coaming191;
    int m_scupper191[string];
    extern task   thwart191(input int fml_u);
    extern function int binnacle191(input int fml_v);
  endclass

  // E1 — the window inside a TASK.
  task Coaming191::thwart191(input int fml_u);
    Rove191 dyn191;
    int     bilge191[$];
    bilge191.push_back(fml_u);
    dyn191 = new[bilge191.size()];
    $display("%0d", dyn191.size());
  endtask

  function int Coaming191::binnacle191(input int fml_v);
    Chine191 hull191[];
    int      cleat191[string];
    int      dowel191[$];
    int      grommet191[$];
    int      halyard191[$];
    Rove191  dyn191;
    Rove191  dup1191;
    Rove191  dup2191;
    Rove191  dup3191;
    Rove191  src191;
    int      slot191[8];
    int      tot191;

    cleat191["a"] = 1;
    dowel191.push_back(2);
    grommet191.push_back(3);
    halyard191.push_back(4);
    hull191 = new[2];
    src191 = new[3];
    slot191[0] = 7;
    tot191 = 0;

    // E2 — a DECLARATION INITIALISER: the enclosing object would not be an
    // assignment.  REMOVED: Surelog's own parser rejects the spelling
    // (`[SNT:PA0207] Syntax error: missing ';' at '['` on
    // `Rove191 init191 = new[cleat191.size()];`), so the face has NO GOLDEN
    // and is a residue, not a cell.  Both our binaries accept it with rc=0.

    // E3 — the base is the FOREACH LOOP VARIABLE itself (a hier_path base
    // reached only through `bind9`'s climb, which takes the same hop).
    foreach (hull191[jx191])
      dyn191 = new[hull191[jx191].strake191.size()];

    // E4 — nested two blocks deep, inside an `if`.
    if (fml_v > 0) begin
      begin
        int mizzen191[string];
        mizzen191["b"] = 5;
        dyn191 = new[mizzen191.size()];
      end
    end

    // E5 — the COPY form: a hier_path base in the SECOND argument.
    dyn191 = new[cleat191.size()](src191);

    // E6 — two windows in one statement.
    dyn191 = new[dowel191.size() + grommet191.size()];

    // E7 — a select INDEX that is itself a hier_path base.
    dyn191 = new[slot191[cleat191.size()]];

    // E8/E9/E10 — the SAME face over three distinct locals, once, twice,
    // three times.
    dup1191 = new[dowel191.size()];
    dup2191 = new[grommet191.size()];
    dup2191 = new[grommet191.size()];
    dup3191 = new[halyard191.size()];
    dup3191 = new[halyard191.size()];
    dup3191 = new[halyard191.size()];

    // E12 — inside a `while` body.
    while (tot191 < 1) begin
      int reef191[$];
      reef191.push_back(6);
      dyn191 = new[reef191.size()];
      tot191 = tot191 + 1;
    end

    // (a class-property `.size()` read here makes Surelog's ELAB pass emit
    //  `[ERR:UH0725] Unresolved hierarchical reference`, so the tally uses
    //  locals only; the class-property FENCE inside the window is arm A's
    //  A5/A6 and arm C's C3, all of which have a clean golden.)
    return tot191 + dyn191.size() + dup1191.size() + dup2191.size() +
           dup3191.size();
  endfunction

  // E11 — a free function cloned into TWO importing packages.
  function automatic int taffrail191(input int fml_w);
    Rove191 dyn191;
    int     painter191[$];
    painter191.push_back(fml_w);
    dyn191 = new[painter191.size()];
    return dyn191.size() + pkgsheer191.size();
  endfunction

endpackage

// FIRST wildcard importer.
package Gudgeonplate191;
  import Futtock191::*;
  int lanyard191 = 22;
  // A TASK, so the E1 task clone is reachable without calling a task from a
  // function.
  task automatic use_gp_t191(output int outv191);
    Coaming191 cm191;
    cm191 = new();
    cm191.thwart191(1);
    outv191 = cm191.binnacle191(2) + taffrail191(3) + lanyard191;
  endtask
endpackage

// SECOND wildcard importer — the same home body cloned again.
package Pintle191;
  import Futtock191::*;
  int ratline191 = 23;
  function automatic int use_pt191();
    return taffrail191(4) + ratline191;
  endfunction
endpackage

module top191e;
  import Gudgeonplate191::*;
  import Pintle191::*;
  int scored191;
  int gpout191;
  initial begin
    use_gp_t191(gpout191);
    scored191 = gpout191 + use_pt191();
    $display("%0d", scored191);
  end
endmodule
