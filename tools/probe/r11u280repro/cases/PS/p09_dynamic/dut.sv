// § pkgNetNamedTsDimEnd280
// a dynamic array and a queue of a struct typedef
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t d [];
  st_t q [$];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
