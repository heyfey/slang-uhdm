// § importCopyTsInstByRole469
// CONTROL: no importing package (the module imports the home), the law does not fire
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
module top;
  import a::*;
  logic [3:0] w = PA;
endmodule
