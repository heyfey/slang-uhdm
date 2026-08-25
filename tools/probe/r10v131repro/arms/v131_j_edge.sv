// v131 arm J — edge shapes: class new(), interface initial, deeper nesting,
// a fork whose only child is a nested EMPTY fork chain.
interface Ijb;
  int q;
  initial begin
    fork : ifaceNamed q = 1; join_none : ifaceNamed
    fork : ifaceEmpty join_any : ifaceEmpty
  end
endinterface
package Pjb;
  class Cnewfork;
    int m;
    function new();
      fork : ctorFork m = 1; join_none : ctorFork
      fork : ctorEmpty join_none : ctorEmpty
    endfunction
    task automatic deep();
      fork : L1
        fork : L2
          fork : L3
            fork : L4 m = 4; join_none : L4
          join_any : L3
        join : L2
      join_none : L1
      fork : E1
        fork : E2
          fork : E3 join_none : E3
        join_any : E2
      join : E1
    endtask
  endclass
endpackage
module Mjb;
  import Pjb::*;
  int z;
  initial begin
    // a fork whose sole child is an empty fork
    fork : soleEmptyKid fork : theNil join_any : theNil join_none : soleEmptyKid
    // three sibling empty forks inside one non-empty fork
    fork : threeNils
      fork : n1 join
      fork : n2 join_any
      fork : n3 join_none
    join : threeNils
    z = 1;
  end
endmodule
