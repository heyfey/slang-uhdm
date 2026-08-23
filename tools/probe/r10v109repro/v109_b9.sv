// r10v109repro/v109_b9.sv - ADVERSARIAL: the SAME class-property name on BOTH
// sides of a `= new` (the lvalue is out of the pool, the constructor ARGUMENT is
// in it), and a class-property index used on both sides.  Tests the MINT SPAN
// when the only in-pool reference is the argument.  MEASUREMENT ONLY.
package pkb9;
  class Pin9;
    int t;
    function new(int a = 0); t = a; endfunction
  endclass
  class Rig9;
    Pin9 selfNewUpsilon;      // written `selfNewUpsilon = new(selfNewUpsilon.t)`
    Pin9 bagNine[4];
    int  bothIdxPsi;          // index on the LHS *and* an argument on the RHS
    int  argOnlyChi;          // argument only (control: golden mints at 20:34)
    extern function void b9set();
  endclass
  function void Rig9::b9set();
    bagNine[bothIdxPsi] = new(bothIdxPsi);   // H1 index BOTH sides
    selfNewUpsilon      = new(argOnlyChi);   // H2 lvalue fenced, arg in the pool
  endfunction
endpackage
import pkb9::*;
module topb9;
  Rig9 r9;
  initial begin r9 = new(); r9.b9set(); end
endmodule
