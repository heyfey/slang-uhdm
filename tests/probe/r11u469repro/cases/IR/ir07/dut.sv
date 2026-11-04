// § importCopyTsInstByRole469
// two importing packages beside a module reading the parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
module top;
  import a::*;
  logic [3:0] w = PA;
endmodule
