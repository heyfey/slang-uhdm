// § clsImpUnsizedBasedRhsCopy243
// signed, octal, binary with x, and a decimal unsized based literal
package p;
  parameter A = 'sh5;
  parameter B = 'o17;
  parameter C = 'b1x0;
  parameter D = 'd12;
  parameter E = 'shF;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
