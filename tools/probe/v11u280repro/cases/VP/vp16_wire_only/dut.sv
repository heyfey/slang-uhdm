// § pkgNetNamedTsDimEnd280
// a wire array of a struct typedef only
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  wire st_t wv [0:1];
endpackage
module top(input pk::st_t i, output logic [3:0] o); assign o = i.a; endmodule
