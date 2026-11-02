// § unitImpTransitiveTds464 (a middle package declared after its importer)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import n::*;
  typedef logic [2:0] m_t;
endpackage
package n;
  import a::*;
  typedef logic [1:0] n_t;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
