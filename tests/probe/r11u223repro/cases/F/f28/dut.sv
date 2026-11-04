// § tfArgScalarTdWriter223 — formals written inside a macro body from an included header
`include "mac.svh"
package p;
  typedef int UVM_FILE;
  class c;
    `MK_SET(set_a)
    `MK_SET(set_b)
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
