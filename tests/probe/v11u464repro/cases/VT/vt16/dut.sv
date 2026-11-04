// § unitImpTransitiveTds464 (a deeper chain whose two branches carry typedefs of one name)
package a;
  typedef logic [3:0] t;
  typedef logic [1:0] u;
endpackage
package b;
  typedef logic [7:0] t;
  typedef logic [5:0] w;
endpackage
package ab;
  import b::*;
endpackage
package abc;
  import a::*;
  import ab::*;
endpackage
package e;
  import abc::*;
  typedef logic [2:0] e_t;
endpackage
import e::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
