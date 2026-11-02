// § cloneLvSharesHomeUnitTs465
// a package queue of class handles read in a package task, two importers in a chain under $unit
package h;
  class W;
    int v;
  endclass
  W pq[$];
  task automatic t();
    foreach (pq[k]) pq[k].v = k;
  endtask
endpackage
package a;
  import h::*;
endpackage
package b;
  import a::*;
endpackage
import b::*;
module top;
endmodule
