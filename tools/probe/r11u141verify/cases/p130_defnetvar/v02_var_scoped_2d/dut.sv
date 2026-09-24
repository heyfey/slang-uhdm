// § defNetVarNoSlot130v
// case v02: var with a package-scoped packed array of two dimensions
package pk;
  typedef logic [1:0] t;
endpackage
module top(output logic [7:0] o);
  var pk::t [1:0][1:0] x;
  assign o = x;
endmodule
