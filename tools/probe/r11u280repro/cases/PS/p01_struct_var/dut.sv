// § pkgNetNamedTsDimEnd280
// a package struct typedef, one variable with an unpacked dimension, used by a module port
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  st_t v [0:1];
endpackage
module top(input pk::st_t i, output logic [7:0] o);
  assign o = i.a;
endmodule
