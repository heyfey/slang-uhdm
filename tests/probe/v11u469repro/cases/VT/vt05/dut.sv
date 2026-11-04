// § importCopyTsInstByRole469
// explicit imports of the typedef and two parameters sharing it
package a;
  typedef logic [3:0] t;
  parameter t P1 = 1;
  parameter t P2 = 4'hf;
endpackage
package b;
  import a::t;
  import a::P1;
  import a::P2;
endpackage
module top;
  logic w;
endmodule
