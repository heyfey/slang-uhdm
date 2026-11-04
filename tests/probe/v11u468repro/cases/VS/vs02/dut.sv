// § specArgPairsImportedFormal468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item, int W = 2);
  T m; bit [W-1:0] n;
endclass
class env;
  C #(item, 4) comp;
endclass
module top; env e; endmodule
