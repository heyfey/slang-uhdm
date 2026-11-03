// § specArgPairsImportedFormal468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
package q;
  import p::*;
  class item; int d; endclass
  class C #(type T = item);
    T m;
  endclass
endpackage
class env;
  q::C #(q::item) comp;
endclass
module top; env e; endmodule
