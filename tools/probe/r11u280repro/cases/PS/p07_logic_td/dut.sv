// § pkgNetNamedTsDimEnd280
// a logic vector typedef element
package pk;
  typedef logic [7:0] b_t;
  b_t q [0:1];
endpackage
module top(input pk::b_t i, output logic o);
  assign o = ^i;
endmodule
