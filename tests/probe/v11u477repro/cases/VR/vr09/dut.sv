// § unitImpRootFileDef477
package p;
  parameter int W = 4;
endpackage
import p::*;
`include "inc.svh"
module top;
  m #(.K(2)) u1();
  m u2();
endmodule
