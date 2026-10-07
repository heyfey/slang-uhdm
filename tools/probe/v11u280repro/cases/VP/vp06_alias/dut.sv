// § pkgNetNamedTsDimEnd280
// a typedef alias of the struct typedef as the element type
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  typedef st_t al_t;
  al_t v [0:1];
endpackage
module top(output logic [3:0] o); assign o = pk::v[0].a; endmodule
