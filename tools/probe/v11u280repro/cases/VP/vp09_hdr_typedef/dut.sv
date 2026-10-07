// § pkgNetNamedTsDimEnd280
// the typedef in an included header, the array in the package file
package pk;
`include "td.svh"
  st_t v [0:1];
endpackage
module top(output logic [3:0] o); assign o = pk::v[0].a; endmodule
