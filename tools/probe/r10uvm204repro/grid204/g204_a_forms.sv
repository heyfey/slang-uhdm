// r10uvm204 arm A — THE INIT FORMS, in a wildcard-import CLONE body.
// One real Surelog golden decides, in ONE file and BOTH views, which for-loop
// INITIALISATION forms give a clone-body reference a `vpiActual`:
//   class-type declaration / typedef-alias declaration / builtin declaration /
//   PLAIN ASSIGNMENT (the fence: it must NOT grow a binding target) /
//   MULTIPLE declared inits / NO init at all.
// Every reference shape golden binds in a clone is exercised on each form: a
// BARE name, a METHOD-CALL PREFIX and a DOTTED member read.
package quarry204;
  class Leaf204;
    int ore204;
    function void assay204(int v204);
    endfunction
  endclass
  typedef Leaf204 LeafAlias204;              // the ALIAS form -> golden ref_var

  class Iter204;
    function Leaf204 first204();
      return null;
    endfunction
    function Leaf204 next204();
      return null;
    endfunction
  endclass

  class Adit204;
    int sink204;
    extern function void winze204();         // OUT-OF-BODY -> the clone's site
  endclass

  function void Adit204::winze204();
    Iter204 it204;
    int     pa204;                           // the PLAIN-ASSIGNMENT loop's var
    it204 = new();
    // FORM 1 — CLASS-TYPE DECLARATION, bare single-statement body.
    for (Leaf204 cA204 = it204.first204(); cA204 != null; cA204 = it204.next204())
      cA204.assay204(1);                     // METHOD-CALL PREFIX
    // FORM 2 — CLASS-TYPE DECLARATION, begin-block body, three reference shapes.
    for (Leaf204 cB204 = it204.first204(); cB204 != null; cB204 = it204.next204())
      begin
        cB204.ore204 = 2;                    // DOTTED member write
        this.sink204 = cB204.ore204;              // DOTTED member read
        cB204.assay204(3);                   // METHOD-CALL PREFIX
      end
    // FORM 3 — TYPEDEF-ALIAS DECLARATION (golden's ref_var kind).
    for (LeafAlias204 cC204 = it204.first204(); cC204 != null; cC204 = it204.next204())
      cC204.assay204(4);
    // FORM 4 — BUILTIN-TYPE DECLARATION.
    for (int iD204 = 0; iD204 < 4; iD204++)
      this.sink204 = iD204;                       // BARE name
    // FORM 5 — PLAIN ASSIGNMENT.  THE FENCE: `pa204` is declared above, not by
    // the loop, so the loop's own Lhs artefact must never become the target.
    for (pa204 = 0; pa204 < 4; pa204++)
      this.sink204 = pa204;
    // FORM 6 — MULTIPLE DECLARED INITS.
    for (int mE204 = 0, nE204 = 1; mE204 < 4; mE204++)
      this.sink204 = mE204 + nE204;
    // FORM 7 — NO INIT AT ALL.
    for (; pa204 < 8; pa204++)
      this.sink204 = pa204;
  endfunction
endpackage

package sluice204;                           // THE WILDCARD IMPORTER
  import quarry204::*;
  class Flume204;
    function void race204();
      Adit204 gate204;
      gate204 = null;
    endfunction
  endclass
endpackage

module top204;
  import sluice204::*;
  initial begin
    Flume204 f204;
    f204 = new();
    f204.race204();
  end
endmodule
