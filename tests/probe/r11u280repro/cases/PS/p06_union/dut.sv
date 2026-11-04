// § pkgNetNamedTsDimEnd280
// a packed union typedef element
package pk;
  typedef union packed { logic [7:0] a; logic [7:0] b; } un_t;
  un_t u [2];
endpackage
module top(input pk::un_t i, output logic o);
  assign o = ^i;
endmodule
