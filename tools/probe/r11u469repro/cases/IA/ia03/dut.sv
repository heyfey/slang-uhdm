// § importCopyTsInstByRole469
// string, real and integer parameters
package a;
  parameter string PS = "hi";
  parameter real PR = 1.5;
  parameter integer PI = 9;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
