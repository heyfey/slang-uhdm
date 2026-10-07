// § pkgNetNamedTsDimEnd280
// two unpacked dimensions on the declarator
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t m [0:1][0:2];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
