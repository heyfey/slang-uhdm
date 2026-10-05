// § unitImpPaRhsOwnCopy243
// two $unit imports and a named item import, and a $unit class
package p;
  parameter A = 'h1;
  parameter B = 2;
endpackage
package q;
  parameter C = 'h3;
  parameter D = 'b11;
endpackage
import p::*;
import q::C;
class env;
  int v;
endclass
module top;
  env e;
  int x = A + C;
endmodule
