// § unitImpTransitiveTds464 (two file-scope imports reaching two typedefs of one name)
package a;
  typedef logic [3:0] t;
endpackage
package b;
  typedef logic [7:0] t;
endpackage
package m;
  import a::*;
endpackage
package n;
  import b::*;
endpackage
import m::*;
import n::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
