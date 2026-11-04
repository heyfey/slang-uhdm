// § unitImpTransitiveTds464 (an explicit file-scope import of t before a wildcard reaching another t)
package a;
  typedef logic [3:0] t;
  typedef logic [2:0] a_t;
endpackage
package p;
  typedef logic [7:0] t;
endpackage
package m;
  import a::*;
endpackage
import p::t;
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
