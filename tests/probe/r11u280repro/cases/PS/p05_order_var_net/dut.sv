// § pkgNetNamedTsDimEnd280
// a variable then a net of one typedef
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v1 [0:2];
  wire st_t n1 [0:1];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
