// § pkgNetNamedTsDimEnd280
// a dimension written with a package parameter expression and a $ bound queue of max size
package pk;
  parameter int N = 4;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:N-1];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
