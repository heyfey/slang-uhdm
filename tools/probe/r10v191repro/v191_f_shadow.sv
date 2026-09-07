// r10v191 ADVERSARIAL ARM F — THE SHADOWING AXIS.
//
// `bind9` resolves a clone-body name by CLIMBING the anchor's parent chain
// innermost-first (`loopVar37` then `blockVar9` at each level), and only
// falls back to the subroutine-level map when the climb runs out.  The
// shipped hop (`up191`) splices the enclosing assignment in where
// § newArray11 cut the chain — so if the hop landed on the WRONG rung, or
// skipped a rung, a name declared at MORE THAN ONE level would bind the
// wrong declaration.  Arms A/C give every declaring scope a UNIQUE name, so
// a mis-aimed hop would still have produced the right object there and the
// column would read TOWARD.
//
// This arm makes the object IDENTITY the discriminator: one name, `keg191`,
// is declared at FOUR nesting levels, and a `new[...]` reads it at each one.
// A hop that lands one rung too high binds the OUTER `keg191` and the cell
// reads MOVED-WRONG rather than TOWARD.  `spar191` does the same across two
// SIBLING foreach blocks (the `uvm_reg::do_check` shape § 181 names), and
// `hasp191` collides a FOREACH LOOP VARIABLE with a function-level local of
// the same name — the one target that is in no `Variables()` listing at all.
//
//   F1  function-level `keg191`, read at function level
//   F2  outer-block `keg191` shadowing it, read in the outer block
//   F3  inner-block `keg191` shadowing both, read in the inner block
//   F4  a foreach-block `keg191`, read inside the foreach
//   F5  `spar191` in the FIRST of two sibling foreach blocks
//   F6  `spar191` in the SECOND — a different object, same name, same depth
//   F7  a foreach LOOP VARIABLE `hasp191` shadowing a function local
//   F8  the function local `hasp191` read AFTER the foreach ends
//   F9  a formal `stave191` shadowed by a block local of the same name
//   F10 the same formal read where nothing shadows it
//
// Names, numbers and orders are deliberately unlike the corpus' and unlike
// arms A/B/C/D/E.
package Ashlar191;

  typedef int Ferrule191[];

  int pkgkeg191[string];

  class Voussoir191;
    extern function int corbel191(input int stave191[$]);
  endclass

  function int Voussoir191::corbel191(input int stave191[$]);
    Ferrule191 dyn191;
    int        keg191[$];          // F1  FUNCTION-LEVEL keg191
    int        hasp191[$];         // F8  FUNCTION-LEVEL hasp191
    int        vane191[3];
    int        tot191;

    keg191.push_back(1);
    hasp191.push_back(2);
    vane191[0] = 3;
    tot191 = 0;

    dyn191 = new[keg191.size()];            // F1 -> the FUNCTION-level keg191
    dyn191 = new[stave191.size()];          // F10 -> the FORMAL stave191

    begin : outer191
      int keg191[string];                   // F2  OUTER-BLOCK keg191
      keg191["a"] = 4;
      dyn191 = new[keg191.size()];          // F2 -> the OUTER-BLOCK keg191
      begin : inner191
        int keg191[];                       // F3  INNER-BLOCK keg191
        keg191 = new[2];
        dyn191 = new[keg191.size()];        // F3 -> the INNER-BLOCK keg191
      end
      begin : shadowfml191
        int stave191[string];               // F9  a BLOCK local shadowing
        stave191["b"] = 6;                  //     the FORMAL of the same name
        dyn191 = new[stave191.size()];      // F9 -> the BLOCK local
      end
    end

    foreach (vane191[fx191]) begin
      int keg191[$];                        // F4  FOREACH-BLOCK keg191
      keg191.push_back(fx191);
      dyn191 = new[keg191.size()];          // F4 -> the FOREACH-BLOCK keg191
    end

    foreach (vane191[gx191]) begin
      int spar191[string];                  // F5  FIRST sibling foreach
      spar191["c"] = 7;
      dyn191 = new[spar191.size()];         // F5 -> the FIRST spar191
    end
    foreach (vane191[hx191]) begin
      int spar191[$];                       // F6  SECOND sibling foreach —
      spar191.push_back(8);                 //     a DIFFERENT object
      dyn191 = new[spar191.size()];         // F6 -> the SECOND spar191
    end

    // F7 — a foreach LOOP VARIABLE named exactly like the function local
    // `hasp191`.  The loop variable is in no `Variables()` listing anywhere;
    // § pkgCloneLoopVarBind37 is the only thing that can reach it.
    foreach (vane191[hasp191])
      dyn191 = new[vane191[hasp191]];

    // F8 — and the FUNCTION-level hasp191 read after the foreach has closed.
    dyn191 = new[hasp191.size()];

    return tot191 + dyn191.size() + pkgkeg191.size();
  endfunction

endpackage

package Springer191;
  import Ashlar191::*;
  int jamb191 = 31;
  function automatic int use_sp191();
    Voussoir191 vs191;
    int         arg191[$];
    arg191.push_back(9);
    vs191 = new();
    return vs191.corbel191(arg191) + jamb191;
  endfunction
endpackage

module top191f;
  import Springer191::*;
  int scored191;
  initial begin
    scored191 = use_sp191();
    $display("%0d", scored191);
  end
endmodule
