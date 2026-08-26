// r10v151 (VERIFIER) arm A — WHAT THE DEGENERATE CALL IS NAMED when the written
// receiver text is not a bare identifier: a SPACED subscript, a package-scoped
// receiver and and a NEWLINE inside the subscript.  Surelog
// names the call `fC->SymName(dollar_or_string)` — the BASE IDENTIFIER — so
// every one of these should be the bare name.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package Apk10;
  int shar10[$];
  int mat10[4][$];
endpackage
package Bpk10;
  import Apk10::*;
  class Namer10;
    int mine10[4][$];
    task nm10;
      int u10;
      u10 = 0;
      mine10 [1].sort() with ( item );          // SPACED subscript
      mine10  [ 2 ].sort() with ( item );       // SPACED, spaces inside too
      mine10[
        3].sort() with ( item );                // NEWLINE inside the subscript
      Apk10::shar10.sort() with ( item );       // PACKAGE-SCOPED receiver
      Apk10::mat10[1].sort() with ( item );     // package-scoped AND indexed
      Apk10::shar10.unique();                   // package-scoped, KEYWORD
      mine10[0].sort() with ( item );           // the CONTROL (tight)
    endtask
  endclass
endpackage
