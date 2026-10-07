// § pkgNetNamedTsDimEnd280
// the typedef in the package file, the array declared in an included header
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
`include "arr.svh"
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
