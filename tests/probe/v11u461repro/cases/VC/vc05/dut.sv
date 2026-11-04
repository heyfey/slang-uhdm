// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
interface ifc;
  import ap::*;
  logic z;
endinterface
module top;
  ifc u();
endmodule
