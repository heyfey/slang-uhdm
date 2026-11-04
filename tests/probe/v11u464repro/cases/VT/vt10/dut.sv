// § unitImpTransitiveTds464 (a diamond: two paths to the same package)
package z;
  typedef logic [3:0] z_t;
endpackage
package a;
  import z::*;
  typedef logic [1:0] a_t;
endpackage
package b;
  import z::*;
  typedef logic [2:0] b_t;
endpackage
package m;
  import a::*;
  import b::*;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
