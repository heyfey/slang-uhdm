// § unitImpTransitiveTds464 (control: abc declared before the packages it imports)
package abc;
  import a::*;
  import b::*;
endpackage
package a;
  typedef logic [3:0] a_t;
endpackage
package b;
  typedef logic [7:0] b_t;
endpackage
package e;
  import abc::*;
endpackage
import e::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
