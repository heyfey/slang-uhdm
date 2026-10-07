// § pkgNetNamedTsDimEnd280
// a scalar of the typedef (no dimension) beside an array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t s;
  st_t v [0:1];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
