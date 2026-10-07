// § pkgNetNamedTsDimEnd280
// the dimension written by a macro (abstains)
`define DIM [0:1]
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v `DIM;
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
