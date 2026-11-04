// § clsImpUnsizedBasedRhsCopy243
// a $unit import of a package parameter (parameter logic [7:0] R = 'hff) inherited by a $unit class (the u01 shape)
package p;
  parameter SB = 4096;
  parameter logic [7:0] R = 'hff;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
