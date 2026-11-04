// § specArgPairsImportedFormal468
// two type arguments written as data types
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
import p::*;
class C #(type T = int, type U = int);
  T m; U n;
endclass
module top;
  C #(byte, logic [3:0]) h;
endmodule
