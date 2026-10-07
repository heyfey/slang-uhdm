// § pkgNetNamedTsDimEnd280
// a module importing the package by wildcard and declaring its own array of the typedef
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:3];
endpackage
module top import pk::*; (output logic [3:0] o);
  st_t w [0:1];
  assign w = '{default: '0};
  assign o = w[0].a ^ v[1].a;
endmodule
