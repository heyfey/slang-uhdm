// § pkgNetNamedTsDimEnd280
// two declarators in one declaration
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v1 [0:1], v2 [0:3];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
