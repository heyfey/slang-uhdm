// § importCopyTsInstByRole469
// the importer re-reads the parameter in a localparam and a module overrides with it
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
  localparam t LB = PA + 1;
endpackage
module sub #(parameter logic [3:0] Q = 0) (); endmodule
module top;
  import b::*;
  sub #(.Q(LB)) u();
endmodule
