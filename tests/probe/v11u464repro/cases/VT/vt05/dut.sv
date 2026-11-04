// § unitImpTransitiveTds464 (a transitive typedef shadowed by its own package import)
package z;
  typedef logic [3:0] t;
  typedef logic [6:0] z_t;
endpackage
package a;
  import z::*;
  typedef logic [5:0] t;
endpackage
package m;
  import a::*;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
