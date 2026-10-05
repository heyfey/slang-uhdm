// § clsImpUnsizedBasedRhsCopy243
// unbased unsized fills imported through $unit and inherited by a $unit class
package p;
  parameter A = '1;
  parameter B = '0;
  parameter C = 'x;
  parameter D = 'z;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
