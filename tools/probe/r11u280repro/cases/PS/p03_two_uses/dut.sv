// § pkgNetNamedTsDimEnd280
// two package entries of one typedef, the later one wins
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v1 [0:1];
  logic [7:0] spacer;
  st_t v2 [0:3];
endpackage
module top(output logic o);
  import pk::*;
  st_t x;
  assign x = '0;
  assign o = x.a[0];
endmodule
