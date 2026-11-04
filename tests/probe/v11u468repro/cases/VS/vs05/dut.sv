// § specArgPairsImportedFormal468
package p;
  typedef int t_t;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item);
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top; env e; endmodule
