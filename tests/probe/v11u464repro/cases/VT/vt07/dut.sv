// § unitImpTransitiveTds464 (class specialization typedefs reached transitively)
package u;
  class S #(type T = int); T v; endclass
endpackage
package a;
  import u::*;
  class it; endclass
  typedef S #(it) a_s;
endpackage
package m;
  import a::*;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
