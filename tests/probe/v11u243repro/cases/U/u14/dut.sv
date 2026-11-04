// § unitImpPaRhsOwnCopy243
// a $unit import of a package parameter (parameter R = 4'b1010) inherited by a $unit class (the u01 shape)
package p;
  parameter SB = 4096;
  parameter R = 4'b1010;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
