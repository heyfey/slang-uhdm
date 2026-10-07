// § pkgNetNamedTsDimEnd280
// the package written in an included header
`include "pk.svh"
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
