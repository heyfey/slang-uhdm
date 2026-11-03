// § specArgPairsImportedFormal468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
package r;
  parameter int RX = 1;
endpackage
import p::*;
import r::*;
class item; int d; endclass
class C #(type T = item, type U = item, type V = item, type W = item);
  T m;
endclass
class env;
  C #(item, int, byte, shortint) comp;
endclass
module top; env e; endmodule
