// § pkgNetNamedTsDimEnd280
// a module declaring its own unpacked array of the package typedef beside the package array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:1];
endpackage
module top(input pk::st_t i, output logic [3:0] o);
  pk::st_t m [0:3];
  assign m = '{default: i};
  assign o = m[2].a;
endmodule
