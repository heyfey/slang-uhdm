// § cloneLoopVarHomeDeclTs259 (the function in a header included by the package)
package p;
  typedef bit unsigned [63:0] addr_t;
  `include "f.svh"
endpackage
package q;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
