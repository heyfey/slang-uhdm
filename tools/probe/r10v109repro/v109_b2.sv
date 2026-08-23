// r10v109repro/v109_b2.sv - ADVERSARIAL: the `this.` / `super.` qualified
// `= new` lvalues and an INHERITED property assigned `= new` from the derived
// body.  (The NONBLOCKING `x <= new()` form is ILLEGAL SystemVerilog - Surelog
// rejects it with PA0207 at the `new` token - so the predicate's
// NonblockingAssignmentExpression arm is unreachable on legal source; see
// v109_b2n.sv for that measurement.)  MEASUREMENT ONLY.
package pkb2;

  class Node2;
    int w;
    function new(int a = 0); w = a; endfunction
  endclass

  class Base2;
    Node2 inhNewPhi;       // assigned `= new` from the DERIVED body via super.
    int   inhPlainChi;     // control
  endclass

  class Kit2 extends Base2;
    Node2 thisNewRho;      // `this.x = new()`
    Node2 plainNewPsi;     // the ordinary blocking control
    int   thisPlainXi;     // `this.x = 4` plain (control, must KEEP its wire)
    extern task b2set();
  endclass

  task Kit2::b2set();
    this.thisNewRho = new(5);   // D3 this.-qualified class-new lvalue
    super.inhNewPhi = new(6);   // D4 super.-qualified class-new lvalue
    plainNewPsi     = new(7);   // D5 the plain control (must be fenced)
    this.thisPlainXi = 4;       // D6 this.-qualified plain LHS
    inhPlainChi      = 8;       // D7 inherited plain (must KEEP its wire)
  endtask

endpackage

import pkb2::*;

module topb2;
  Kit2 k2;
  initial begin
    k2 = new();
    k2.b2set();
  end
endmodule
