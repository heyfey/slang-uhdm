// § clsImpUnsizedBasedRhsCopy243
// a $unit import of a package parameter (parameter [7:0] R = 'h5) inherited by a $unit class (the u01 shape)
package p;
  parameter SB = 4096;
  parameter [7:0] R = 'h5;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
