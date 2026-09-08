// r10uvm206 grid arm C — THE TYPE-PARAMETER TYPEDEF IS NOT A REPRESENTATIVE
// (§ classRepresentativeSkipsTypeParamAlias25).  `typedef T elem_type;` inside
// cc206_holder hands its typespec to the PARAMETER, never to the class the
// parameter resolves to, so cc206_target keeps a null typespec and NO class
// key of its own reaches the design listing.  cc206_named, named by a plain
// typedef, is the positive control in the same arm.
package pc206;
  class cc206_target;
    int g;
  endclass
  class cc206_named;
    int h;
  endclass
  class cc206_holder #(type T = cc206_target);
    typedef T elem_type;
    T e;
  endclass
  class cc206_user;
    typedef cc206_named named_type;
    cc206_named u;
  endclass
endpackage

import pc206::*;

module gc206;
  cc206_holder #(cc206_target) c0;
  cc206_user c1;
endmodule
