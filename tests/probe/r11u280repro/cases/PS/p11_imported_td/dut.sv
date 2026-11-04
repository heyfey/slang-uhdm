// § pkgNetNamedTsDimEnd280
// an element typedef from another package
package pa;
  typedef struct packed { logic [3:0] a; } st_t;
endpackage
package pk;
  import pa::*;
  st_t v [0:1];
endpackage
module top(input pa::st_t i, output logic o);
  assign o = ^i;
endmodule
