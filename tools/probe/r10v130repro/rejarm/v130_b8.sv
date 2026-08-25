// r10v130repro/v130_b8.sv — VERIFIER ARM b8: the GENUINELY UNDECLARED NAME.
// The brief's last name face.  slang REJECTS an undeclared identifier, so this
// arm's only job is to record that BOTH binaries reject it IDENTICALLY (a
// symmetric reject is not a regression) and that Surelog accepts it and mints.
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package pkUndecl130v;
  class cUndecl130v;
    int dynUndecl130v[];
    extern function void undeclRunner130v();
  endclass
  function void cUndecl130v::undeclRunner130v();
    dynUndecl130v = new[neverDeclaredKsi130v];
  endfunction
endpackage

import pkUndecl130v::*;

module topUndecl130v;
  initial begin
    cUndecl130v hUndecl130v;
    hUndecl130v = new();
    hUndecl130v.undeclRunner130v();
  end
endmodule
