// § pkgNetNamedTsDimEnd280
// a struct with an int member (variable road: abstains)
package pk;
  typedef struct packed { int x; logic [7:0] y; } si_t;
  si_t sv [0:1];
endpackage
module top(input pk::si_t i, output logic o);
  assign o = ^i;
endmodule
