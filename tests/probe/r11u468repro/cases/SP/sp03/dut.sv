// § specArgPairsImportedFormal468
// a class in a package whose body imports p, specialized in a module (one import item, two args)
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
package q;
  import p::*;
  class C #(type T = int, type U = int, type W = int);
    T m;
  endclass
endpackage
module top;
  q::C #(byte, shortint, int) h;
endmodule
