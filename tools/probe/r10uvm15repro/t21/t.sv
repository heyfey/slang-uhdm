// Does the class living in ANOTHER INCLUDED FILE change class_typespec
// naming?  UVM's out-of-body `uvm_component::m_set_cl_verb` NAMES its
// `uvm_cmdline_processor clp;` while t20's same-file out-of-body method
// leaves it unnamed.  Everything here is one package spread over includes,
// exactly UVM's shape.
package pk;
  `include "a.svh"
  `include "b.svh"

  // same-file package function, class from a.svh
  function void fPkgInT();
    Early g;
    g = new();
  endfunction
endpackage

module top;
  import pk::*;
  initial;
endmodule
