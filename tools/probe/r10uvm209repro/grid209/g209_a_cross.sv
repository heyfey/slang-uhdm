// r10uvm209 grid arm A — THE CROSS: source scope x kind.
// One package whose listing carries, side by side, package-scope declarations
// of every kind this pass touches AND the out-of-body constructor body locals
// of the same kinds.  A module wildcard-imports it at FILE scope, so its DEF
// and ELAB views each materialise the package's whole listing.
// The question: which vpiAutomatic does each copy carry?
package pa209;
  class cb209;
    int n;
  endclass
  // --- package-scope declarations, one per kind ---------------------------
  cb209  pa_cls;                 // bare NamedType -> net_declaration shape
  cb209  pa_cls_new = new();     // `new` initialiser -> data_declaration
  int    pa_int = 3;
  string pa_str = "pa";
  int    pa_assoc[string];
  // --- the OUT-OF-BODY constructor whose body locals Surelog hoists -------
  class cc209;
    int q;
    extern function new();
  endclass
  function cc209::new();
    cb209  lo_cls;               // the head's shape: a bare class handle
    int    lo_int;
    string lo_str;
    int    lo_assoc[string];
    begin
      cb209 lo_nest;             // one level deeper, inside a `begin`
      lo_nest = null;
    end
    lo_cls = null;
    lo_int = 0;
    lo_str = "";
    q = 1;
  endfunction
endpackage

import pa209::*;

module ga209;
  cb209 mo_cls;                  // the module's OWN variable — must stay static
  int   mo_int;
  initial $display("%0d", pa_int);
endmodule
