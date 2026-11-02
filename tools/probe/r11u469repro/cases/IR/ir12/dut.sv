// § importCopyTsInstByRole469
// CONTROL: a typedef of a typedef (three hops in golden), the law abstains
package a;
  typedef logic [3:0] t1;
  typedef t1 t2;
  parameter t2 PA = 1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
