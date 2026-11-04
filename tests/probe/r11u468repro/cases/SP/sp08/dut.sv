// § specArgPairsImportedFormal468
// a value parameter first, then the type parameter
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
import p::*;
class C #(int N = 1, type T = int);
  T m;
endclass
module top;
  C #(4, byte) h;
endmodule
