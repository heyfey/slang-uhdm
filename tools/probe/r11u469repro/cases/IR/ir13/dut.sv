// § importCopyTsInstByRole469
// CONTROL: the parameter's typedef comes from a third package, the law abstains
package z;
  typedef logic [5:0] t;
endpackage
package a;
  import z::*;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
