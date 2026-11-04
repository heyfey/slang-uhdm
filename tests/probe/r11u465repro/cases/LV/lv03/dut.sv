// § cloneLvSharesHomeUnitTs465
// a package queue of class handles in a package function (uvm_init's shape)
package h;
  class W;
    function void init(); endfunction
  endclass
  W pq[$];
  function void g();
    foreach (pq[k]) pq[k].init();
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
