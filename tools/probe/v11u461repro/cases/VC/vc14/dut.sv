// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
  int pv;
endpackage
package ap;
  import p::*;
endpackage
program prg;
  import ap::*;
endprogram
module top;
endmodule
