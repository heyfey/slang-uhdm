// § specArgPairsImportedFormal468
// a $unit class under a file-scope import, one type argument written as a class name
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = int);
  T m;
endclass
module top;
  C #(item) h;
endmodule
