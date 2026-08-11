// r10uvm47 arm t65b — GOLDEN-ONLY.  The FORWARD-reference half of
// § pkgInitRefBindsOwnListing47.
//
// slang enforces the LRM ("identifier used before its declaration") and REJECTS
// this file, so it is read with Surelog alone (goldfile.sh), exactly as pass 46
// read its written-`static`-lifetime cell.  The question it answers: does
// Surelog's package data-declaration binding depend on DECLARATION ORDER, or
// does it resolve against the finished listing?  If forward references bind too,
// the law needs NO order gate; if they do not, the gate is "declared earlier in
// the listing" and a law without it has an unmeasured half.
//
// uvm-1.2 has only the BACKWARD spelling (uvm_object_globals.svh:637 references
// :610), so this cell is the only place the question can be asked.
package q1;
  int f_back  = f_first;   // CORRECTED LABEL: this is ALSO A FORWARD reference --
                           // f_first is declared on the NEXT line. t65b holds no
                           // backward control at all; t65a is the backward
                           // control. (Pass-47 verifier; immaterial to the
                           // forward cell this arm proves, but the old label
                           // "backward: known to bind" misreads the arm.)
  int f_first = 5;
  int f_fwd   = f_late;    // FORWARD: the cell
  int f_late  = 9;
endpackage
