// § ifaceDynTdElabVar251 (a package dynamic typedef imported into the interface body)
package p;
  typedef logic [3:0] d_t [];
endpackage
interface ifc;
  import p::*;
  d_t d;
endinterface
module top; ifc i(); endmodule
