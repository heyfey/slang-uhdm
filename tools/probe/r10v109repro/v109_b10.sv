// r10v109repro/v109_b10.sv - ADVERSARIAL: a PACKAGE-LEVEL VARIABLE of the same
// name as the fenced class property (law 88's window), a class-property name
// reached through a FUNCTION CALL and a CAST inside the `= new` lvalue's index,
// and a MODULE-NESTED class (no package home at all).  MEASUREMENT ONLY.
package pkbA;

  int shadowPkgTheta;          // a PACKAGE variable with the property's name

  class CellA;
    int y;
    function new(int a = 0); y = a; endfunction
  endclass

  function int pickA(int v); return v & 3; endfunction

  class RigA;
    CellA bagA[4];
    CellA shadowPkgTheta;      // SAME NAME as the package variable, `= new` lvalue
    int   callIdxRho;          // inside a CALL inside the lvalue's index
    int   castIdxTau;          // inside a CAST inside the lvalue's index
    int   plainCtlA;           // control
    extern function void bAset();
  endclass

  function void RigA::bAset();
    shadowPkgTheta       = new(1);                 // J1 shadows a package variable
    bagA[pickA(callIdxRho)] = new(2);              // J2 call argument inside the index
    bagA[int'(castIdxTau)]  = new(3);              // J3 cast inside the index
    plainCtlA            = 4;                      // J4 control
  endfunction

endpackage

import pkbA::*;

module topbA;
  // a MODULE-NESTED class: no package home, so the hoist pool never applies
  class NestedA;
    CellA nestNewIota;
    function void nset(); nestNewIota = new(5); endfunction
  endclass
  RigA    rA;
  NestedA nA;
  initial begin
    rA = new(); rA.bAset();
    nA = new(); nA.nset();
  end
endmodule
