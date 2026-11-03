// § modImpCopyTdChainHomeTop473
// two importer packages each with a t-typed parameter
package a;
  typedef logic [3:0] t;
endpackage
package b1;
  import a::*;
  parameter t P1 = 5;
endpackage
package b2;
  import a::*;
  parameter t P2 = 6;
endpackage
module top(output logic [3:0] y);
  import b1::*;
  import b2::*;
  assign y = P1 | P2;
endmodule
