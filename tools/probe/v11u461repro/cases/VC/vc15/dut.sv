// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  parameter u_t P = 8'h3c;
endpackage
module top(output logic [7:0] o);
  import ap::*;
  assign o = P;
endmodule
