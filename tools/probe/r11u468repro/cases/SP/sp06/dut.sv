// § specArgPairsImportedFormal468
// control: an imported package without parameters
package p;
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
