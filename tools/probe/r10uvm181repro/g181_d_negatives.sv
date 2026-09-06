// r10uvm181 arm D -- THE NEGATIVES.
//
// Removing `if (!lm9.empty())` turns the WHOLE of law pkgCloneHierBind9 /
// law pkgCloneLocalRefBind37 / law pkgCloneMember10 on for a clone body that owns
// nothing at its own level, not just the loop variable.  This arm is every
// name in such a body that golden must STILL leave bare, so an over-wide
// reading shows up as an EXTRA cell rather than as silence:
//
//   * a CLASS PROPERTY reached bare (law 37: null in golden's clone)
//   * `this`
//   * a PACKAGE-level variable of the home package
//   * a member of a CLASS-scope struct typedef (law pkgCloneMember10's LAW-PCB
//     witness: class-scope types are invisible from the clone's symbol table)
//   * a member of a PACKAGE-scope struct typedef, which DOES resolve -- the
//     positive control that proves the arm can see a binding at all
//   * the implicit RETURN variable of a class method
//     (law classRetNameDefViewNoBind37: never bound in a clone)
//
// every one of them inside an EMPTYTF body, alongside the same names inside a
// HASLOCALS twin so the two columns can be read against each other.
package vellum181_home;

  typedef struct packed { logic [3:0] folio; logic [3:0] quire; } codex181_t;

  int        parch181_pkgvar;
  codex181_t parch181_pkgstruct;

  class vellum181_cls;
    typedef struct packed { logic [3:0] rubric; logic [3:0] gloss; } incun181_t;
    int        vellum181_prop [4];
    int        vellum181_scalar;
    incun181_t vellum181_clsstruct;

    extern function int emptybody181();
    extern function int haslocal181();
  endclass

  // EMPTYTF: no formals, no function-scope declaration.  (A named function
  // return is NOT a Variables() entry, so this really is the empty shape.)
  function int vellum181_cls::emptybody181();
    foreach (vellum181_prop[colophon]) begin
      int marginalia;
      marginalia = vellum181_prop[colophon];      // property: BARE in golden
      marginalia = marginalia + this.vellum181_scalar;         // this: BARE
      marginalia = marginalia + parch181_pkgvar;               // pkg var
      marginalia = marginalia + int'(parch181_pkgstruct.folio); // pkg struct member
      marginalia = marginalia + int'(vellum181_clsstruct.rubric); // class struct member
      emptybody181 = marginalia + colophon;                    // return name
    end
  endfunction

  // The HASLOCALS twin: identical body, one function-scope local.  Every cell
  // here already read golden's answer before the law and must not move.
  function int vellum181_cls::haslocal181();
    int palimpsest;
    foreach (vellum181_prop[uncial]) begin
      int marginalia;
      marginalia = vellum181_prop[uncial];
      marginalia = marginalia + this.vellum181_scalar;
      marginalia = marginalia + parch181_pkgvar;
      marginalia = marginalia + int'(parch181_pkgstruct.folio);
      marginalia = marginalia + int'(vellum181_clsstruct.rubric);
      palimpsest = marginalia + uncial;
      haslocal181 = palimpsest;
    end
  endfunction

  // A FREE function, EMPTYTF, reading only package-scope names -- no class at
  // all, so law classRetNameDefViewNoBind37 cannot mask anything here.
  function automatic int quill181_fn();
    foreach (parch181_pkgstruct[nib]) begin
      int marginalia;
      marginalia = int'(parch181_pkgstruct[nib]) + nib + parch181_pkgvar;
      quill181_fn = marginalia;
    end
  endfunction

endpackage

package vellum181_imp;
  import vellum181_home::*;
  int vellum181_anchor;
endpackage

module vellum181_top;
  initial vellum181_imp::vellum181_anchor = 0;
endmodule
