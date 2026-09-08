// v209 verifier arm N — AN OUT-OF-BODY CONSTRUCTOR IN A MODULE-SCOPE CLASS,
// and one in a class nested inside a package class.  Neither is a package
// member's constructor; nothing of theirs may reach a package or module
// variable listing, and the module's own variables must stay unmarked.
package pn209;
  class cn209a;
    int n;
  endclass
  cn209a pn_h;
endpackage

module gn209;
  import pn209::*;
  class cn209m;
    int q;
    extern function new();
  endclass
  function cn209m::new();
    cn209a ln_h;
    int    ln_i;
    ln_h = null;
    q = 9;
  endfunction
  cn209m mn_obj;
  int    mn_i;
  initial begin
    mn_obj = new();
    $display("n");
  end
endmodule
