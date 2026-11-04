// § importCopyTsInstByRole469
// an explicit import of the parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::PA;
endpackage
module top;
  logic w;
endmodule
