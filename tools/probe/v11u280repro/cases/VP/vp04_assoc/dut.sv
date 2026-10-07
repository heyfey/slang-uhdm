// § pkgNetNamedTsDimEnd280
// an associative array and a queue of the typedef beside a fixed array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t q [$];
  st_t m [int];
  st_t f [0:1];
endpackage
module top(output logic [3:0] o); assign o = pk::f[0].a; endmodule
