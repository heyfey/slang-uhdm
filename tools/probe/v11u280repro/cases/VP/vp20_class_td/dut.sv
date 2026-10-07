// § pkgNetNamedTsDimEnd280
// a class-scoped typedef of a struct as the element type of a package array
package pk;
  class c; typedef struct packed { logic [3:0] a; } st_t; endclass
  c::st_t v [0:1];
endpackage
module top(output logic o); assign o = 1'b0; endmodule
