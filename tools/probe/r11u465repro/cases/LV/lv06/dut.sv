// § cloneLvSharesHomeUnitTs465
// control: a string formal (uvm_has_wildcard's shape), the home answers the formal's own string_typespec
package h;
  function bit has(string x);
    foreach (x[i]) if (x[i] == "*") return 1;
    return 0;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
