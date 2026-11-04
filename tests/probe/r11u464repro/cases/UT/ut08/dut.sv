// § unitImpTransitiveTds464 (an interface and a module in the importing file)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
endpackage
import m::*;
interface ifc;
  logic [3:0] v;
endinterface
module top(input logic [1:0] i, output logic [1:0] o);
  ifc u();
  assign o = i;
endmodule
