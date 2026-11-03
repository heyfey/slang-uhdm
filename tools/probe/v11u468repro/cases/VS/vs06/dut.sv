// § specArgPairsImportedFormal468
package p;
  parameter int PA = 2;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item, type U = int, type V = int);
  T m;
endclass
class env;
  C #(item, byte, shortint) comp;
endclass
module top; env e; endmodule
