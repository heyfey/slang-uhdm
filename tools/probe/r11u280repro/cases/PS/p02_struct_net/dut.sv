// § pkgNetNamedTsDimEnd280
// a wire of a package struct typedef with an unpacked dimension
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  wire st_t n [3];
endpackage
module top(input pk::st_t i, output logic [7:0] o);
  assign o = i.b;
endmodule
