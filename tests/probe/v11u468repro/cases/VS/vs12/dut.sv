// § specArgPairsImportedFormal468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item);
  T m;
endclass
class env;
  typedef C #(item) ci_t;
  ci_t comp;
endclass
module top; env e; endmodule
