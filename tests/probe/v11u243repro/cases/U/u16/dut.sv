// § unitImpPaRhsOwnCopy243
// a $unit import of a package parameter (parameter bit [3:0] R = 4'd3) inherited by a $unit class (the u01 shape)
package p;
  parameter SB = 4096;
  parameter bit [3:0] R = 4'd3;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
