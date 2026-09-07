// r10v200 break arm 1 — CLASS-SCOPE constants in the range of a clone's
// declarations.  These are resolvable at COMPILE time inside the class, so
// Surelog may never late-bind them: if golden's clone keeps the actual and we
// decline it, this arm reads AWAY-GOLDEN.
package pv1;
  parameter WPK = 7;
  class Cbase;
    localparam int CLP = 4;
    function logic [CLP:0] mlp(input logic [CLP:0] a);
      logic [CLP:0] loclp;
      loclp = a;
      mlp = loclp;
    endfunction
    function logic [WPK:0] mpk(input logic [WPK:0] b);
      mpk = b;
    endfunction
  endclass
  class Cpar #(int PW = 6);
    function logic [PW:0] mpw(input logic [PW:0] c);
      logic [PW:0] locpw;
      locpw = c;
      mpw = locpw;
    endfunction
  endclass
  class Cext;
    localparam int ELP = 5;
    extern function logic [ELP:0] mext(input logic [ELP:0] d);
  endclass
  function logic [Cext::ELP:0] Cext::mext(input logic [ELP:0] d);
    logic [ELP:0] locext;
    locext = d;
    mext = locext;
  endfunction
endpackage

package pv1imp;
  import pv1::*;
endpackage

module topv1;
  import pv1::*;
  initial $display(WPK);
endmodule
