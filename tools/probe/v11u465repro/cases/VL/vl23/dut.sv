// § cloneLvSharesHomeUnitTs465
// a package queue of ints read in a package function (not class handles)
package h;
  int pq[$];
  function void g();
    foreach (pq[k]) pq[k] = k;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
