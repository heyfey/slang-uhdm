// § specArgPairsImportedFormal468
// the specialization written in a typedef
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
import p::*;
class C #(type T = int);
  T m;
endclass
typedef C #(byte) cb_t;
module top;
  cb_t h;
endmodule
