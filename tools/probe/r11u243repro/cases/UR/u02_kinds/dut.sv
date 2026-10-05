// § clsImpUnsizedBasedRhsCopy243
// value kinds of imported package parameters: unsized based, sized based, decimal, string, typed, an expression
package p;
  parameter A = 'hf000000;
  parameter B = 32'h10;
  parameter int unsigned C = 'h7;
  parameter D = 'b101;
  parameter string S = "uvm";
  parameter E = A + 1;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
