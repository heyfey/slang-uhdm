// § pkgNetNamedTsDimEnd280
// the typedef written by a macro, the array dimension written plainly
`define TD(n) typedef struct packed { logic [3:0] a; } n;
package pk;
  `TD(st_t)
  st_t v [0:1];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
