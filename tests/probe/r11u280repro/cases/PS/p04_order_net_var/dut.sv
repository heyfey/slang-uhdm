// § pkgNetNamedTsDimEnd280
// a net then a variable of one typedef, on different lines
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  wire st_t n1 [0:1];
  st_t v1 [0:2];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
