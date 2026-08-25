// r10uvm146 arm C — OWNERS: the same package imported by a module, by a
// program, by a nested package and by a class's CONTAINER package, and NOWHERE
// at $unit.  The design listing must stay EMPTY: this is the arm that can
// convict an over-firing law.  (A package import written directly in a class
// declaration is illegal and slang rejects it, so the class arm imports through
// its container package — which is also the shape § classInheritsContainerImports23
// already models.)
package own_pk;
  parameter OWN_A = 21;
  parameter own_b = 22;
endpackage

package outer_pk;
  import own_pk::*;                  // package-scope import (nested packages)
  parameter OUT_C = OWN_A + 1;

  class c_owner;
    function int f();
      return OWN_A + own_b;
    endfunction
  endclass
endpackage

program p_owner(output int po);
  import own_pk::*;
  assign po = own_b;
endprogram

module c_owners(output int m1, output int m2);
  import own_pk::*;
  import outer_pk::*;
  assign m1 = OWN_A + OUT_C;
  assign m2 = own_b;
endmodule
