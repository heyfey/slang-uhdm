// r10uvm121 VERIFIER arm D — the LAW MEETING OTHER LAWS.  An out-of-block
// reference inside the `new` argument list (the § oobRefVarLocalHoistNet107
// hoisted-net family: emptying the RHS must not delete a net golden keeps), a
// COVERGROUP `new` (the predicate deliberately declines it — § covergroupNewCall7
// owns that site), and § thisSuperNewAssignNoStmt3's DROP slots re-stated in a
// vocabulary of their own so the drop cannot be undercut.
package kiln;

int oob_heat;                       // package-level, OUT OF the class block
int oob_soak;

class Sagger;
   int firing;
   function new(int f = 0); firing = f; endfunction
endclass

class Muffle;
   Sagger door;
   Sagger vent;
   Sagger flue;
   Sagger damper;
   Sagger spy;
   Sagger port[];
   int cone;
   covergroup cg_cone;
      coverpoint cone;
   endgroup

   function new(int c);
      cone       = c;
      this.door  = new(oob_heat);        // D01 KEPT slot, arg is an OOB ref
      this.vent  = new(oob_heat + oob_soak);  // D02 KEPT slot, two OOB refs
      this.cg_cone = new;                // D03 covergroup new (declined by §121)
   endfunction

   function void bisque(int k);
      // DROP slots — golden emits NO element; both binaries must agree
      begin
         this.flue = new;                // D04 begin-list element  -> dropped
         cone = 1;
      end
      fork
         this.damper = new;              // D05 fork arm            -> dropped
      join_none
      begin : peep
         this.spy = new;                 // D06 named begin         -> dropped
      end
      this.port = new[k];                // D07 function-body list  -> dropped
      cone = 2;
   endfunction

   function void glaze();
      this.flue = new;                   // D08 WHOLE body of a plain function
   endfunction
endclass

endpackage

module kiln_top;
  import kiln::*;
  Muffle m;
  initial begin
    m = new(6);
    m.bisque(2);
  end
endmodule
