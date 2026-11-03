// § specArgPairsImportedFormal468
// the specialization inside another $unit class (the scoreboard shape)
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item);
  typedef C #(T) this_type;
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top;
  env e;
endmodule
