// § unitImpTransitiveTds464 (a three-level chain with typedefs at every level)
package a;
  typedef logic [3:0] a_t;
endpackage
package b;
  import a::*;
  typedef logic [4:0] b_t;
endpackage
package c;
  import b::*;
  typedef logic [5:0] c_t;
endpackage
import c::*;
module top(input logic [1:0] i, output logic [1:0] o);
  c_t q;
  assign q = '0;
  assign o = i;
endmodule
