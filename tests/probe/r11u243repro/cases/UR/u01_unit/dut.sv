// § clsImpUnsizedBasedRhsCopy243
// a $unit import of a package parameter with an unsized based literal value, inherited by a $unit class
package p;
  parameter SB = 4096;
  parameter RADIX = 'hf000000;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
