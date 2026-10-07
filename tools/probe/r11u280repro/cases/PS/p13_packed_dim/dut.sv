// § pkgNetNamedTsDimEnd280
// a packed dimension on the typedef'd element and an unpacked one
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t [1:0] p;
  st_t [1:0] pu [0:1];
endpackage
module top(input pk::st_t i, output logic o);
  assign o = ^i;
endmodule
