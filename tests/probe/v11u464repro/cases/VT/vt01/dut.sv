// § unitImpTransitiveTds464 (the importing package declares its own t beside a transitive t)
package a;
  typedef logic [3:0] t;
  typedef logic [4:0] a_t;
endpackage
package e;
  import a::*;
  typedef logic [7:0] t;
endpackage
import e::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
