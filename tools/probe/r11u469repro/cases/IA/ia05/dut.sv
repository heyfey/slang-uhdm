// § importCopyTsInstByRole469
// two home packages each with a typedef named t
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package z;
  typedef logic [5:0] t;
  parameter t PZ = 2;
endpackage
package b;
  import a::PA;
  import z::PZ;
endpackage
module top;
  logic w;
endmodule
