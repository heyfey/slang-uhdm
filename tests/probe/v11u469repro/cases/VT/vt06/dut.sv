// § importCopyTsInstByRole469
// b re-exports a, a module reads the value through b (downstream)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
package b;
  import a::*;
  import a::PA;
  export a::PA;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PA;
endmodule
